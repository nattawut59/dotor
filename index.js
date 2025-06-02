const express = require('express');
const mysql = require('mysql2/promise');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const multer = require('multer');
const nodemailer = require('nodemailer');
const cron = require('node-cron');
const { v4: uuidv4 } = require('uuid');
const cors = require('cors');
const path = require('path');
const fs = require('fs');

const app = express();
app.use(cors());
app.use(express.json());

// Serve static files from the 'uploads' directory
app.use('/uploads', express.static('uploads'));

// Create uploads directory if it doesn't exist
if (!fs.existsSync('uploads')) {
  fs.mkdirSync('uploads');
}

// Database connection pool
const pool = mysql.createPool({
  host: process.env.DB_HOST || 'gateway01.us-west-2.prod.aws.tidbcloud.com',
  user: process.env.DB_USER || '417ZsdFRiJocQ5b.root',
  password: process.env.DB_PASSWORD || 'RZOglKRbYa339z3N',
  database: process.env.DB_NAME || 'glaucoma_management_system',
  port: process.env.DB_PORT || 4000,
  ssl: {
    rejectUnauthorized: false
  },
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// Test database connection
pool.getConnection()
  .then(connection => {
    console.log('✅ Database connection successful');
    connection.release();
  })
  .catch(err => {
    console.error('❌ Database connection failed:', err.message);
  });

// File upload configuration
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({ 
  storage: storage,
  fileFilter: (req, file, cb) => {
    if (file.mimetype === 'application/pdf' || file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Only PDF and image files are allowed'));
    }
  },
  limits: {
    fileSize: 10 * 1024 * 1024 // 10MB limit
  }
});

// Authentication middleware for Doctors
const authDoctor = async (req, res, next) => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '');
    if (!token) {
      return res.status(401).json({ error: 'Access denied. No token provided.' });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'your-secret-key');

    if (decoded.role !== 'doctor') {
      return res.status(403).json({ error: 'Access denied. Doctor role required.' });
    }

    const [doctors] = await pool.execute(
      `SELECT d.doctor_id, d.first_name, d.last_name, d.license_number, 
              d.department, d.specialty, u.email, u.phone
       FROM DoctorProfiles d
       JOIN Users u ON d.doctor_id = u.user_id
       WHERE d.doctor_id = ? AND u.role = 'doctor' AND u.status = 'active'`,
      [decoded.userId]
    );

    if (doctors.length === 0) {
      return res.status(401).json({ error: 'Invalid token or doctor not found.' });
    }

    req.doctor = doctors[0];
    next();
  } catch (error) {
    res.status(401).json({ error: 'Invalid token.' });
  }
};

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'OK',
    message: 'Doctor API is running',
    timestamp: new Date().toISOString()
  });
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'Glaucoma Management System - Doctor API',
    version: '1.0.0',
    endpoints: [
      'POST /api/doctors/register',
      'POST /api/doctors/login',
      'GET /api/doctors/profile',
      'PUT /api/doctors/profile',
      'GET /api/patients',
      'GET /api/patients/:patientId',
      'POST /api/patients/:patientId/medications',
      'GET /api/patients/:patientId/medications',
      'PUT /api/medications/:prescriptionId',
      'DELETE /api/medications/:prescriptionId',
      'POST /api/patients/:patientId/iop-measurements',
      'GET /api/patients/:patientId/iop-measurements',
      'POST /api/patients/:patientId/surgeries',
      'GET /api/patients/:patientId/surgeries',
      'POST /api/patients/:patientId/treatment-plans',
      'GET /api/patients/:patientId/treatment-plan',
      'PUT /api/treatment-plans/:planId',
      'POST /api/patients/:patientId/special-tests',
      'GET /api/patients/:patientId/special-tests',
      'GET /api/special-tests/:testId/details',
      'GET /api/patients/:patientId/special-tests/compare',
      'GET /api/appointments/upcoming',
      'GET /api/adherence-alerts',
      'PUT /api/adherence-alerts/:alertId/resolve',
      'GET /api/dashboard/stats',
      'POST /api/patients/:patientId/assign'
    ]
  });
});

// ===========================================
// DOCTOR AUTHENTICATION ROUTES
// ===========================================

// Doctor Registration
app.post('/api/doctors/register', async (req, res) => {
  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();

    const {
      email, password, firstName, lastName, licenseNumber,
      phone, department, specialty, education, hospitalAffiliation
    } = req.body;

    // Validation
    if (!email || !password || !firstName || !lastName || !licenseNumber) {
      await connection.rollback();
      return res.status(400).json({ error: 'Required fields missing' });
    }

    // Check if doctor already exists
    const [existingUser] = await connection.execute(
      'SELECT user_id FROM Users WHERE email = ?',
      [email]
    );

    if (existingUser.length > 0) {
      await connection.rollback();
      return res.status(400).json({ error: 'Doctor already registered with this email' });
    }

    // Check license number
    const [existingLicense] = await connection.execute(
      'SELECT doctor_id FROM DoctorProfiles WHERE license_number = ?',
      [licenseNumber]
    );

    if (existingLicense.length > 0) {
      await connection.rollback();
      return res.status(400).json({ error: 'License number already registered' });
    }

    const userId = uuidv4();
    const hashedPassword = await bcrypt.hash(password, 10);

    // Create user
    await connection.execute(
      `INSERT INTO Users (user_id, role, password_hash, email, phone, 
                         require_password_change, status)
       VALUES (?, 'doctor', ?, ?, ?, 0, 'active')`,
      [userId, hashedPassword, email, phone]
    );

    // Create doctor profile
    await connection.execute(
      `INSERT INTO DoctorProfiles (
        doctor_id, first_name, last_name, license_number, department,
        specialty, education, hospital_affiliation, registration_date, status
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, CURDATE(), 'active')`,
      [userId, firstName, lastName, licenseNumber, department, specialty, education, hospitalAffiliation]
    );

    await connection.commit();

    // Generate JWT token
    const token = jwt.sign(
      { userId: userId, role: 'doctor' },
      process.env.JWT_SECRET || 'your-secret-key',
      { expiresIn: '7d' }
    );

    res.status(201).json({
      message: 'Doctor registered successfully',
      token,
      doctor: {
        id: userId,
        firstName,
        lastName,
        email,
        licenseNumber,
        department,
        specialty
      }
    });
  } catch (error) {
    await connection.rollback();
    console.error('Registration error:', error);
    res.status(500).json({ error: error.message });
  } finally {
    connection.release();
  }
});

// Doctor Login
app.post('/api/doctors/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    const [doctors] = await pool.execute(
      `SELECT u.user_id, u.password_hash, u.status, d.first_name, d.last_name,
              d.license_number, d.department, d.specialty, u.email
       FROM Users u
       JOIN DoctorProfiles d ON u.user_id = d.doctor_id
       WHERE u.email = ? AND u.role = 'doctor'`,
      [email]
    );

    if (doctors.length === 0) {
      return res.status(400).json({ error: 'Invalid email or password' });
    }

    const doctor = doctors[0];

    if (doctor.status !== 'active') {
      return res.status(400).json({ error: 'Account is not active' });
    }

    const isValidPassword = await bcrypt.compare(password, doctor.password_hash);
    if (!isValidPassword) {
      return res.status(400).json({ error: 'Invalid email or password' });
    }

    // Update last login
    await pool.execute(
      'UPDATE Users SET last_login = NOW() WHERE user_id = ?',
      [doctor.user_id]
    );

    const token = jwt.sign(
      { userId: doctor.user_id, role: 'doctor' },
      process.env.JWT_SECRET || 'your-secret-key',
      { expiresIn: '7d' }
    );

    res.json({
      message: 'Login successful',
      token,
      doctor: {
        id: doctor.user_id,
        firstName: doctor.first_name,
        lastName: doctor.last_name,
        email: doctor.email,
        licenseNumber: doctor.license_number,
        department: doctor.department,
        specialty: doctor.specialty
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get Doctor Profile
app.get('/api/doctors/profile', authDoctor, async (req, res) => {
  try {
    const [profile] = await pool.execute(
      `SELECT d.*, u.email, u.phone, u.created_at, u.last_login
       FROM DoctorProfiles d
       JOIN Users u ON d.doctor_id = u.user_id
       WHERE d.doctor_id = ?`,
      [req.doctor.doctor_id]
    );

    res.json(profile[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Update Doctor Profile
app.put('/api/doctors/profile', authDoctor, async (req, res) => {
  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();

    const {
      firstName, lastName, department, specialty, education, 
      hospitalAffiliation, phone, bio, consultationHours
    } = req.body;

    // Update doctor profile
    await connection.execute(
      `UPDATE DoctorProfiles SET 
       first_name = ?, last_name = ?, department = ?, specialty = ?,
       education = ?, hospital_affiliation = ?, bio = ?, consultation_hours = ?
       WHERE doctor_id = ?`,
      [firstName, lastName, department, specialty, education, 
       hospitalAffiliation, bio, consultationHours, req.doctor.doctor_id]
    );

    // Update user phone if provided
    if (phone) {
      await connection.execute(
        'UPDATE Users SET phone = ? WHERE user_id = ?',
        [phone, req.doctor.doctor_id]
      );
    }

    await connection.commit();
    res.json({ message: 'Profile updated successfully' });
  } catch (error) {
    await connection.rollback();
    res.status(500).json({ error: error.message });
  } finally {
    connection.release();
  }
});

// ===========================================
// PATIENT MANAGEMENT ROUTES
// ===========================================

// Get all patients under doctor's care
app.get('/api/patients', authDoctor, async (req, res) => {
    try {
        // แสดงผู้ป่วยทั้งหมด แทนที่จะกรองตาม doctor
        const [patients] = await pool.execute(`
            SELECT patient_id, hn, first_name, last_name, date_of_birth, 
                   gender, registration_date
            FROM PatientProfiles 
            ORDER BY registration_date DESC
        `);
        
        res.json(patients);
    } catch (error) {
        console.error('Error getting patients:', error);
        res.status(500).json({ error: error.message });
    }
});

// Get specific patient with complete medical info
app.get('/api/patients/:patientId', authDoctor, async (req, res) => {
  try {
    const patientId = req.params.patientId;

    // Verify patient is under doctor's care
    const [relationship] = await pool.execute(
      `SELECT relationship_id FROM DoctorPatientRelationships
       WHERE doctor_id = ? AND patient_id = ? AND status = 'active'`,
      [req.doctor.doctor_id, patientId]
    );

    if (relationship.length === 0) {
      return res.status(403).json({ error: 'Patient not under your care' });
    }

    // Get patient basic info
    const [patients] = await pool.execute(
      `SELECT p.*, u.email, u.phone,
              TIMESTAMPDIFF(YEAR, p.date_of_birth, CURDATE()) as age
       FROM PatientProfiles p
       JOIN Users u ON p.patient_id = u.user_id
       WHERE p.patient_id = ?`,
      [patientId]
    );

    if (patients.length === 0) {
      return res.status(404).json({ error: 'Patient not found' });
    }

    const patient = patients[0];

    // Get latest IOP measurements
    const [latestIOP] = await pool.execute(
      `SELECT * FROM IOP_Measurements 
       WHERE patient_id = ? 
       ORDER BY measurement_date DESC, measurement_time DESC 
       LIMIT 5`,
      [patientId]
    );

    // Get active medications
    const [medications] = await pool.execute(
      `SELECT pm.*, m.name as medication_name, m.generic_name
       FROM PatientMedications pm
       JOIN Medications m ON pm.medication_id = m.medication_id
       WHERE pm.patient_id = ? AND pm.status = 'active'
       ORDER BY pm.start_date DESC`,
      [patientId]
    );

    // Get medical history
    const [medicalHistory] = await pool.execute(
      `SELECT * FROM PatientMedicalHistory 
       WHERE patient_id = ? 
       ORDER BY recorded_at DESC`,
      [patientId]
    );

    // Get active treatment plan
    const [treatmentPlan] = await pool.execute(
      `SELECT * FROM GlaucomaTreatmentPlans 
       WHERE patient_id = ? AND status = 'active' 
       ORDER BY start_date DESC 
       LIMIT 1`,
      [patientId]
    );

    res.json({
      ...patient,
      latestIOP,
      medications,
      medicalHistory,
      treatmentPlan: treatmentPlan[0] || null
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Assign patient to doctor
app.post('/api/patients/:patientId/assign', authDoctor, async (req, res) => {
  try {
    const patientId = req.params.patientId;

    // Check if patient exists
    const [patient] = await pool.execute(
      'SELECT patient_id FROM PatientProfiles WHERE patient_id = ?',
      [patientId]
    );

    if (patient.length === 0) {
      return res.status(404).json({ error: 'Patient not found' });
    }

    // Check if relationship already exists
    const [existing] = await pool.execute(
      `SELECT relationship_id FROM DoctorPatientRelationships
       WHERE doctor_id = ? AND patient_id = ?`,
      [req.doctor.doctor_id, patientId]
    );

    if (existing.length > 0) {
      // Reactivate if inactive
      await pool.execute(
        `UPDATE DoctorPatientRelationships 
         SET status = 'active', end_date = NULL 
         WHERE doctor_id = ? AND patient_id = ?`,
        [req.doctor.doctor_id, patientId]
      );
    } else {
      // Create new relationship
      const relationshipId = uuidv4();
      await pool.execute(
        `INSERT INTO DoctorPatientRelationships 
         (relationship_id, doctor_id, patient_id, start_date, status)
         VALUES (?, ?, ?, CURDATE(), 'active')`,
        [relationshipId, req.doctor.doctor_id, patientId]
      );
    }

    res.json({ message: 'Patient assigned successfully' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ===========================================
// MEDICATION MANAGEMENT ROUTES
// ===========================================

// Get patient's medications
app.get('/api/patients/:patientId/medications', authDoctor, async (req, res) => {
  try {
    const patientId = req.params.patientId;

    // Verify access
    const [relationship] = await pool.execute(
      `SELECT relationship_id FROM DoctorPatientRelationships
       WHERE doctor_id = ? AND patient_id = ? AND status = 'active'`,
      [req.doctor.doctor_id, patientId]
    );

    if (relationship.length === 0) {
      return res.status(403).json({ error: 'Patient not under your care' });
    }

    const [medications] = await pool.execute(
      `SELECT pm.prescription_id, pm.eye, pm.dosage, pm.frequency, pm.start_date,
              pm.end_date, pm.status, pm.special_instructions, pm.prescribed_date,
              m.name as medication_name, m.generic_name, m.category, m.form, m.strength,
              CONCAT(d.first_name, ' ', d.last_name) as prescribed_by
       FROM PatientMedications pm
       JOIN Medications m ON pm.medication_id = m.medication_id
       JOIN DoctorProfiles d ON pm.doctor_id = d.doctor_id
       WHERE pm.patient_id = ?
       ORDER BY pm.start_date DESC`,
      [patientId]
    );

    res.json(medications);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Add/Prescribe medication for patient
app.post('/api/patients/:patientId/medications', authDoctor, async (req, res) => {
  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();

    const patientId = req.params.patientId;
    const {
      medicationName, genericName, category, form, strength,
      eye, dosage, frequency, duration, specialInstructions,
      quantityDispensed, refills
    } = req.body;

    // Verify patient access
    const [relationship] = await connection.execute(
      `SELECT relationship_id FROM DoctorPatientRelationships
       WHERE doctor_id = ? AND patient_id = ? AND status = 'active'`,
      [req.doctor.doctor_id, patientId]
    );

    if (relationship.length === 0) {
      await connection.rollback();
      return res.status(403).json({ error: 'Patient not under your care' });
    }

    // Check if medication exists, if not create it
    let [medication] = await connection.execute(
      'SELECT medication_id FROM Medications WHERE name = ? AND generic_name = ?',
      [medicationName, genericName]
    );

    let medicationId;
    if (medication.length === 0) {
      medicationId = uuidv4();
      await connection.execute(
        `INSERT INTO Medications (medication_id, name, generic_name, category, form, strength, status)
         VALUES (?, ?, ?, ?, ?, ?, 'active')`,
        [medicationId, medicationName, genericName, category, form, strength]
      );
    } else {
      medicationId = medication[0].medication_id;
    }

    // Create prescription
    const prescriptionId = uuidv4();
    const startDate = new Date().toISOString().split('T')[0];
    let endDate = null;

    if (duration) {
      const end = new Date();
      end.setDate(end.getDate() + parseInt(duration));
      endDate = end.toISOString().split('T')[0];
    }

    await connection.execute(
      `INSERT INTO PatientMedications (
        prescription_id, patient_id, medication_id, doctor_id, prescribed_date,
        start_date, end_date, eye, dosage, frequency, duration, 
        quantity_dispensed, refills, special_instructions, status
      ) VALUES (?, ?, ?, ?, CURDATE(), ?, ?, ?, ?, ?, ?, ?, ?, ?, 'active')`,
      [prescriptionId, patientId, medicationId, req.doctor.doctor_id,
       startDate, endDate, eye, dosage, frequency, duration,
       quantityDispensed, refills, specialInstructions]
    );

    await connection.commit();

    res.status(201).json({
      prescriptionId,
      message: 'Medication prescribed successfully'
    });
  } catch (error) {
    await connection.rollback();
    res.status(500).json({ error: error.message });
  } finally {
    connection.release();
  }
});

// Update medication prescription
app.put('/api/medications/:prescriptionId', authDoctor, async (req, res) => {
  try {
    const prescriptionId = req.params.prescriptionId;
    const {
      dosage, frequency, duration, specialInstructions,
      status, discontinuedReason
    } = req.body;

    // Verify prescription belongs to doctor's patient
    const [prescription] = await pool.execute(
      `SELECT pm.prescription_id FROM PatientMedications pm
       JOIN DoctorPatientRelationships dpr ON pm.patient_id = dpr.patient_id
       WHERE pm.prescription_id = ? AND dpr.doctor_id = ? AND dpr.status = 'active'`,
      [prescriptionId, req.doctor.doctor_id]
    );

    if (prescription.length === 0) {
      return res.status(403).json({ error: 'Prescription not found or unauthorized' });
    }

    const updateFields = [];
    const updateValues = [];

    if (dosage) {
      updateFields.push('dosage = ?');
      updateValues.push(dosage);
    }
    if (frequency) {
      updateFields.push('frequency = ?');
      updateValues.push(frequency);
    }
    if (duration) {
      updateFields.push('duration = ?');
      updateValues.push(duration);
    }
    if (specialInstructions) {
      updateFields.push('special_instructions = ?');
      updateValues.push(specialInstructions);
    }
    if (status) {
      updateFields.push('status = ?');
      updateValues.push(status);
    }
    if (discontinuedReason) {
      updateFields.push('discontinued_reason = ?');
      updateValues.push(discontinuedReason);
    }

    if (updateFields.length === 0) {
      return res.status(400).json({ error: 'No fields to update' });
    }

    updateValues.push(prescriptionId);

    await pool.execute(
      `UPDATE PatientMedications SET ${updateFields.join(', ')}, updated_at = NOW() 
       WHERE prescription_id = ?`,
      updateValues
    );

    res.json({ message: 'Medication updated successfully' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Discontinue medication
app.delete('/api/medications/:prescriptionId', authDoctor, async (req, res) => {
  try {
    const prescriptionId = req.params.prescriptionId;
    const { reason } = req.body;

    // Verify prescription belongs to doctor's patient
    const [prescription] = await pool.execute(
      `SELECT pm.prescription_id FROM PatientMedications pm
       JOIN DoctorPatientRelationships dpr ON pm.patient_id = dpr.patient_id
       WHERE pm.prescription_id = ? AND dpr.doctor_id = ? AND dpr.status = 'active'`,
      [prescriptionId, req.doctor.doctor_id]
    );

    if (prescription.length === 0) {
      return res.status(403).json({ error: 'Prescription not found or unauthorized' });
    }

    await pool.execute(
      `UPDATE PatientMedications 
       SET status = 'discontinued', discontinued_reason = ?, end_date = CURDATE(), updated_at = NOW()
       WHERE prescription_id = ?`,
      [reason || 'Discontinued by doctor', prescriptionId]
    );

    res.json({ message: 'Medication discontinued successfully' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ===========================================
// IOP MEASUREMENTS ROUTES
// ===========================================

// Add IOP measurement
app.post('/api/patients/:patientId/iop-measurements', authDoctor, async (req, res) => {
  try {
    const patientId = req.params.patientId;
    const {
      measurementDate, measurementTime, leftEyeIOP, rightEyeIOP,
      measurementDevice, measurementMethod, notes
    } = req.body;

    // Verify patient access
    const [relationship] = await pool.execute(
      `SELECT relationship_id FROM DoctorPatientRelationships
       WHERE doctor_id = ? AND patient_id = ? AND status = 'active'`,
      [req.doctor.doctor_id, patientId]
    );

    if (relationship.length === 0) {
      return res.status(403).json({ error: 'Patient not under your care' });
    }

    const measurementId = uuidv4();

    await pool.execute(
      `INSERT INTO IOP_Measurements (
        measurement_id, patient_id, recorded_by, measurement_date, measurement_time,
        left_eye_iop, right_eye_iop, measurement_device, measurement_method, 
        notes, measured_at_hospital
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1)`,
      [measurementId, patientId, req.doctor.doctor_id, measurementDate,
       measurementTime, leftEyeIOP, rightEyeIOP, measurementDevice, 
       measurementMethod, notes]
    );

    res.status(201).json({
      measurementId,
      message: 'IOP measurement recorded successfully'
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get IOP measurements for patient with analytics
app.get('/api/patients/:patientId/iop-measurements', authDoctor, async (req, res) => {
  try {
    const patientId = req.params.patientId;
    const { startDate, endDate, limit = 50 } = req.query;

    // Verify patient access
    const [relationship] = await pool.execute(
      `SELECT relationship_id FROM DoctorPatientRelationships
       WHERE doctor_id = ? AND patient_id = ? AND status = 'active'`,
      [req.doctor.doctor_id, patientId]
    );

    if (relationship.length === 0) {
      return res.status(403).json({ error: 'Patient not under your care' });
    }

    let whereClause = 'WHERE iop.patient_id = ?';
    let queryParams = [patientId];

    if (startDate) {
      whereClause += ' AND iop.measurement_date >= ?';
      queryParams.push(startDate);
    }
    if (endDate) {
      whereClause += ' AND iop.measurement_date <= ?';
      queryParams.push(endDate);
    }

    const [measurements] = await pool.execute(
      `SELECT iop.measurement_id, iop.measurement_date, iop.measurement_time,
              iop.left_eye_iop, iop.right_eye_iop, iop.measurement_device,
              iop.measurement_method, iop.notes, iop.measured_at_hospital,
              CONCAT(d.first_name, ' ', d.last_name) as recorded_by_name
       FROM IOP_Measurements iop
       LEFT JOIN DoctorProfiles d ON iop.recorded_by = d.doctor_id
       ${whereClause}
       ORDER BY iop.measurement_date DESC, iop.measurement_time DESC
       LIMIT ?`,
      [...queryParams, parseInt(limit)]
    );

    // Get statistics
    const [stats] = await pool.execute(
      `SELECT 
         AVG(left_eye_iop) as avg_left_iop,
         AVG(right_eye_iop) as avg_right_iop,
         MAX(left_eye_iop) as max_left_iop,
         MAX(right_eye_iop) as max_right_iop,
         MIN(left_eye_iop) as min_left_iop,
         MIN(right_eye_iop) as min_right_iop,
         COUNT(*) as total_measurements
       ${whereClause}`,
      queryParams
    );

    res.json({
      measurements,
      statistics: stats[0] || {}
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ===========================================
// SURGERY MANAGEMENT ROUTES
// ===========================================

// Add glaucoma surgery record
app.post('/api/patients/:patientId/surgeries', authDoctor, async (req, res) => {
  try {
    const patientId = req.params.patientId;
    const {
      surgeryDate, surgeryType, eye, preOpIOPLeft, preOpIOPRight,
      procedureDetails, complications, postOpCare, outcome, followUpPlan, notes
    } = req.body;

    // Verify patient access
    const [relationship] = await pool.execute(
      `SELECT relationship_id FROM DoctorPatientRelationships
       WHERE doctor_id = ? AND patient_id = ? AND status = 'active'`,
      [req.doctor.doctor_id, patientId]
    );

    if (relationship.length === 0) {
      return res.status(403).json({ error: 'Patient not under your care' });
    }

    const surgeryId = uuidv4();

    await pool.execute(
      `INSERT INTO GlaucomaSurgeries (
        surgery_id, patient_id, doctor_id, surgery_date, surgery_type, eye,
        pre_op_iop_left, pre_op_iop_right, procedure_details, complications,
        post_op_care, outcome, follow_up_plan, notes
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [surgeryId, patientId, req.doctor.doctor_id, surgeryDate, surgeryType, eye,
       preOpIOPLeft, preOpIOPRight, procedureDetails, complications,
       postOpCare, outcome, followUpPlan, notes]
    );

    res.status(201).json({
      surgeryId,
      message: 'Surgery record created successfully'
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get surgeries for patient
app.get('/api/patients/:patientId/surgeries', authDoctor, async (req, res) => {
  try {
    const patientId = req.params.patientId;

    // Verify patient access
    const [relationship] = await pool.execute(
      `SELECT relationship_id FROM DoctorPatientRelationships
       WHERE doctor_id = ? AND patient_id = ? AND status = 'active'`,
      [req.doctor.doctor_id, patientId]
    );

    if (relationship.length === 0) {
      return res.status(403).json({ error: 'Patient not under your care' });
    }

    const [surgeries] = await pool.execute(
      `SELECT gs.surgery_id, gs.surgery_date, gs.surgery_type, gs.eye,
              gs.pre_op_iop_left, gs.pre_op_iop_right, gs.procedure_details,
              gs.complications, gs.outcome, gs.notes, gs.report_url,
              CONCAT(d.first_name, ' ', d.last_name) as surgeon_name
       FROM GlaucomaSurgeries gs
       LEFT JOIN DoctorProfiles d ON gs.doctor_id = d.doctor_id
       WHERE gs.patient_id = ?
       ORDER BY gs.surgery_date DESC`,
      [patientId]
    );

    res.json(surgeries);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ===========================================
// TREATMENT PLAN ROUTES
// ===========================================

// Create/Update treatment plan
app.post('/api/patients/:patientId/treatment-plans', authDoctor, async (req, res) => {
  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();

    const patientId = req.params.patientId;
    const {
      treatmentApproach, targetIOPLeft, targetIOPRight,
      followUpFrequency, visualFieldTestFrequency, notes
    } = req.body;

    // Verify patient access
    const [relationship] = await connection.execute(
      `SELECT relationship_id FROM DoctorPatientRelationships
       WHERE doctor_id = ? AND patient_id = ? AND status = 'active'`,
      [req.doctor.doctor_id, patientId]
    );

    if (relationship.length === 0) {
      await connection.rollback();
      return res.status(403).json({ error: 'Patient not under your care' });
    }

    // Mark existing active plans as completed
    await connection.execute(
      `UPDATE GlaucomaTreatmentPlans 
       SET status = 'completed', end_date = CURDATE()
       WHERE patient_id = ? AND status = 'active'`,
      [patientId]
    );

    // Create new treatment plan
    const treatmentPlanId = uuidv4();

    await connection.execute(
      `INSERT INTO GlaucomaTreatmentPlans (
        treatment_plan_id, patient_id, doctor_id, start_date, treatment_approach,
        target_iop_left, target_iop_right, follow_up_frequency,
        visual_field_test_frequency, notes, status
      ) VALUES (?, ?, ?, CURDATE(), ?, ?, ?, ?, ?, ?, 'active')`,
      [treatmentPlanId, patientId, req.doctor.doctor_id, treatmentApproach,
       targetIOPLeft, targetIOPRight, followUpFrequency, visualFieldTestFrequency, notes]
    );

    await connection.commit();

    res.status(201).json({
      treatmentPlanId,
      message: 'Treatment plan created successfully'
    });
  } catch (error) {
    await connection.rollback();
    res.status(500).json({ error: error.message });
  } finally {
    connection.release();
  }
});

// Get treatment plan for patient
app.get('/api/patients/:patientId/treatment-plan', authDoctor, async (req, res) => {
  try {
    const patientId = req.params.patientId;

    // Verify patient access
    const [relationship] = await pool.execute(
      `SELECT relationship_id FROM DoctorPatientRelationships
       WHERE doctor_id = ? AND patient_id = ? AND status = 'active'`,
      [req.doctor.doctor_id, patientId]
    );

    if (relationship.length === 0) {
      return res.status(403).json({ error: 'Patient not under your care' });
    }

    const [plans] = await pool.execute(
      `SELECT gtp.treatment_plan_id, gtp.start_date, gtp.end_date, gtp.treatment_approach,
              gtp.target_iop_left, gtp.target_iop_right, gtp.follow_up_frequency,
              gtp.visual_field_test_frequency, gtp.notes, gtp.status,
              CONCAT(d.first_name, ' ', d.last_name) as created_by_name
       FROM GlaucomaTreatmentPlans gtp
       LEFT JOIN DoctorProfiles d ON gtp.doctor_id = d.doctor_id
       WHERE gtp.patient_id = ?
       ORDER BY gtp.start_date DESC`,
      [patientId]
    );

    res.json(plans);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Update treatment plan
app.put('/api/treatment-plans/:planId', authDoctor, async (req, res) => {
  try {
    const planId = req.params.planId;
    const {
      treatmentApproach, targetIOPLeft, targetIOPRight,
      followUpFrequency, visualFieldTestFrequency, notes, status
    } = req.body;

    // Verify plan belongs to doctor's patient
    const [plan] = await pool.execute(
      `SELECT gtp.treatment_plan_id FROM GlaucomaTreatmentPlans gtp
       JOIN DoctorPatientRelationships dpr ON gtp.patient_id = dpr.patient_id
       WHERE gtp.treatment_plan_id = ? AND dpr.doctor_id = ? AND dpr.status = 'active'`,
      [planId, req.doctor.doctor_id]
    );

    if (plan.length === 0) {
      return res.status(403).json({ error: 'Treatment plan not found or unauthorized' });
    }

    const updateFields = [];
    const updateValues = [];

    if (treatmentApproach) {
      updateFields.push('treatment_approach = ?');
      updateValues.push(treatmentApproach);
    }
    if (targetIOPLeft !== undefined) {
      updateFields.push('target_iop_left = ?');
      updateValues.push(targetIOPLeft);
    }
    if (targetIOPRight !== undefined) {
      updateFields.push('target_iop_right = ?');
      updateValues.push(targetIOPRight);
    }
    if (followUpFrequency) {
      updateFields.push('follow_up_frequency = ?');
      updateValues.push(followUpFrequency);
    }
    if (visualFieldTestFrequency) {
      updateFields.push('visual_field_test_frequency = ?');
      updateValues.push(visualFieldTestFrequency);
    }
    if (notes) {
      updateFields.push('notes = ?');
      updateValues.push(notes);
    }
    if (status) {
      updateFields.push('status = ?');
      updateValues.push(status);
      if (status === 'completed') {
        updateFields.push('end_date = CURDATE()');
      }
    }

    if (updateFields.length === 0) {
      return res.status(400).json({ error: 'No fields to update' });
    }

    updateValues.push(planId);

    await pool.execute(
      `UPDATE GlaucomaTreatmentPlans SET ${updateFields.join(', ')}, updated_at = NOW() 
       WHERE treatment_plan_id = ?`,
      updateValues
    );

    res.json({ message: 'Treatment plan updated successfully' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ===========================================
// SPECIAL TESTS ROUTES (OCT, CTVF)
// ===========================================

// Upload special test results with PDF
app.post('/api/patients/:patientId/special-tests', authDoctor, upload.single('pdfFile'), async (req, res) => {
  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();

    const patientId = req.params.patientId;
    const { testType, testDate, eye, testDetails, results, notes } = req.body;

    // Verify patient access
    const [relationship] = await connection.execute(
      `SELECT relationship_id FROM DoctorPatientRelationships
       WHERE doctor_id = ? AND patient_id = ? AND status = 'active'`,
      [req.doctor.doctor_id, patientId]
    );

    if (relationship.length === 0) {
      await connection.rollback();
      return res.status(403).json({ error: 'Patient not under your care' });
    }

    // Create a visit record
    const visitId = uuidv4();
    await connection.execute(
      `INSERT INTO PatientVisits (
        visit_id, patient_id, doctor_id, visit_date, visit_time, visit_type, visit_status
      ) VALUES (?, ?, ?, ?, TIME(NOW()), 'Special Test', 'completed')`,
      [visitId, patientId, req.doctor.doctor_id, testDate]
    );

    const testId = uuidv4();
    const reportUrl = req.file ? req.file.filename : null;

    await connection.execute(
      `INSERT INTO SpecialEyeTests (
        test_id, patient_id, doctor_id, test_date, test_type, eye,
        test_details, results, report_url, notes, visit_id
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [testId, patientId, req.doctor.doctor_id, testDate, testType, eye,
       testDetails, results, reportUrl, notes, visitId]
    );

    // If OCT test, parse and add detailed results
    if (testType === 'OCT' && results) {
      try {
        const resultsData = JSON.parse(results);
        const octId = uuidv4();

        await connection.execute(
          `INSERT INTO OCT_Results (
            oct_id, test_id, left_avg_rnfl, right_avg_rnfl, left_superior_rnfl,
            right_superior_rnfl, left_inferior_rnfl, right_inferior_rnfl,
            left_cup_disc_ratio, right_cup_disc_ratio
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
          [octId, testId, resultsData.leftAvgRNFL, resultsData.rightAvgRNFL,
           resultsData.leftSuperiorRNFL, resultsData.rightSuperiorRNFL,
           resultsData.leftInferiorRNFL, resultsData.rightInferiorRNFL,
           resultsData.leftCupDiscRatio, resultsData.rightCupDiscRatio]
        );
      } catch (parseError) {
        console.warn('Failed to parse OCT results:', parseError);
      }
    }

    await connection.commit();

    res.status(201).json({
      testId,
      message: 'Special test results recorded successfully',
      reportUrl: reportUrl ? `/uploads/${reportUrl}` : null
    });
  } catch (error) {
    await connection.rollback();
    res.status(500).json({ error: error.message });
  } finally {
    connection.release();
  }
});

// Get special tests for patient
app.get('/api/patients/:patientId/special-tests', authDoctor, async (req, res) => {
  try {
    const patientId = req.params.patientId;
    const { testType, startDate, endDate } = req.query;

    // Verify patient access
    const [relationship] = await pool.execute(
      `SELECT relationship_id FROM DoctorPatientRelationships
       WHERE doctor_id = ? AND patient_id = ? AND status = 'active'`,
      [req.doctor.doctor_id, patientId]
    );

    if (relationship.length === 0) {
      return res.status(403).json({ error: 'Patient not under your care' });
    }

    let whereClause = 'WHERE set.patient_id = ?';
    let queryParams = [patientId];

    if (testType) {
      whereClause += ' AND set.test_type = ?';
      queryParams.push(testType);
    }
    if (startDate) {
      whereClause += ' AND set.test_date >= ?';
      queryParams.push(startDate);
    }
    if (endDate) {
      whereClause += ' AND set.test_date <= ?';
      queryParams.push(endDate);
    }

    const [tests] = await pool.execute(
      `SELECT set.test_id, set.test_date, set.test_type, set.eye,
              set.test_details, set.results, set.report_url, set.notes,
              CONCAT(d.first_name, ' ', d.last_name) as performed_by
       FROM SpecialEyeTests set
       LEFT JOIN DoctorProfiles d ON set.doctor_id = d.doctor_id
       ${whereClause}
       ORDER BY set.test_date DESC`,
      queryParams
    );

    // Format report URLs
    const formattedTests = tests.map(test => ({
      ...test,
      report_url: test.report_url ? `/uploads/${test.report_url}` : null
    }));

    res.json(formattedTests);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get detailed special test result
app.get('/api/special-tests/:testId/details', authDoctor, async (req, res) => {
  try {
    const testId = req.params.testId;

    const [testDetails] = await pool.execute(
      `SELECT set.test_id, set.test_date, set.test_type, set.eye,
              set.test_details, set.results, set.report_url, set.notes,
              oct.left_avg_rnfl, oct.right_avg_rnfl, oct.left_superior_rnfl,
              oct.right_superior_rnfl, oct.left_inferior_rnfl, oct.right_inferior_rnfl,
              oct.left_cup_disc_ratio, oct.right_cup_disc_ratio,
              CONCAT(d.first_name, ' ', d.last_name) as performed_by
       FROM SpecialEyeTests set
       LEFT JOIN OCT_Results oct ON set.test_id = oct.test_id
       LEFT JOIN DoctorProfiles d ON set.doctor_id = d.doctor_id
       JOIN DoctorPatientRelationships dpr ON set.patient_id = dpr.patient_id
       WHERE set.test_id = ? AND dpr.doctor_id = ? AND dpr.status = 'active'`,
      [testId, req.doctor.doctor_id]
    );

    if (testDetails.length === 0) {
      return res.status(404).json({ error: 'Special test not found or not accessible' });
    }

    const test = testDetails[0];
    test.report_url = test.report_url ? `/uploads/${test.report_url}` : null;

    res.json(test);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Compare special test results
app.get('/api/patients/:patientId/special-tests/compare', authDoctor, async (req, res) => {
  try {
    const patientId = req.params.patientId;
    const { testType, fromDate, toDate } = req.query;

    if (!testType || !fromDate || !toDate) {
      return res.status(400).json({ error: 'testType, fromDate, and toDate are required' });
    }

    // Verify patient access
    const [relationship] = await pool.execute(
      `SELECT relationship_id FROM DoctorPatientRelationships
       WHERE doctor_id = ? AND patient_id = ? AND status = 'active'`,
      [req.doctor.doctor_id, patientId]
    );

    if (relationship.length === 0) {
      return res.status(403).json({ error: 'Patient not under your care' });
    }

    const [tests] = await pool.execute(
      `SELECT set.test_id, set.test_date, set.test_type, set.results,
              oct.left_avg_rnfl, oct.right_avg_rnfl, oct.left_superior_rnfl,
              oct.right_superior_rnfl, oct.left_inferior_rnfl, oct.right_inferior_rnfl,
              oct.left_cup_disc_ratio, oct.right_cup_disc_ratio
       FROM SpecialEyeTests set
       LEFT JOIN OCT_Results oct ON set.test_id = oct.test_id
       WHERE set.patient_id = ? AND set.test_type = ? 
         AND set.test_date BETWEEN ? AND ?
       ORDER BY set.test_date ASC`,
      [patientId, testType, fromDate, toDate]
    );

    // Calculate progression/improvement
    const comparison = tests.map((test, index) => {
      if (index === 0) return { ...test, change: null };

      const prevTest = tests[index - 1];
      const change = {};

      // Calculate changes for OCT RNFL values
      if (test.left_avg_rnfl !== null && prevTest.left_avg_rnfl !== null) {
        change.leftAvgRNFL = test.left_avg_rnfl - prevTest.left_avg_rnfl;
      }
      if (test.right_avg_rnfl !== null && prevTest.right_avg_rnfl !== null) {
        change.rightAvgRNFL = test.right_avg_rnfl - prevTest.right_avg_rnfl;
      }
      if (test.left_superior_rnfl !== null && prevTest.left_superior_rnfl !== null) {
        change.leftSuperiorRNFL = test.left_superior_rnfl - prevTest.left_superior_rnfl;
      }
      if (test.right_superior_rnfl !== null && prevTest.right_superior_rnfl !== null) {
        change.rightSuperiorRNFL = test.right_superior_rnfl - prevTest.right_superior_rnfl;
      }
      if (test.left_inferior_rnfl !== null && prevTest.left_inferior_rnfl !== null) {
        change.leftInferiorRNFL = test.left_inferior_rnfl - prevTest.left_inferior_rnfl;
      }
      if (test.right_inferior_rnfl !== null && prevTest.right_inferior_rnfl !== null) {
        change.rightInferiorRNFL = test.right_inferior_rnfl - prevTest.right_inferior_rnfl;
      }
      // Cup-to-Disc Ratio changes
      if (test.left_cup_disc_ratio !== null && prevTest.left_cup_disc_ratio !== null) {
        change.leftCupDiscRatio = test.left_cup_disc_ratio - prevTest.left_cup_disc_ratio;
      }
      if (test.right_cup_disc_ratio !== null && prevTest.right_cup_disc_ratio !== null) {
        change.rightCupDiscRatio = test.right_cup_disc_ratio - prevTest.right_cup_disc_ratio;
      }

      return { ...test, change };
    });

    res.json(comparison);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ===========================================
// APPOINTMENT MANAGEMENT
// ===========================================

// Get upcoming appointments for the doctor
app.get('/api/appointments/upcoming', authDoctor, async (req, res) => {
    try {
        const days = parseInt(req.query.days) || 7;
        
        const [appointments] = await pool.execute(`
            SELECT a.appointment_id, a.appointment_date, a.appointment_time,
                   a.appointment_type, p.first_name, p.last_name, p.hn
            FROM Appointments a
            JOIN PatientProfiles p ON a.patient_id = p.patient_id
            WHERE a.appointment_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL ? DAY)
            AND a.appointment_status = 'scheduled'
            ORDER BY a.appointment_date ASC, a.appointment_time ASC
        `, [days]);
        
        res.json(appointments);
    } catch (error) {
        console.error('Error getting appointments:', error);
        res.status(500).json({ error: error.message });
    }
});

// ===========================================
// MEDICATION ADHERENCE AND ALERTS
// ===========================================

// Get adherence alerts for the doctor
app.get('/api/adherence-alerts', authDoctor, async (req, res) => {
    try {
        const status = req.query.status || 'pending';
        const limit = parseInt(req.query.limit) || 10;
        
        const [alerts] = await pool.execute(`
            SELECT a.alert_id, a.created_at as alert_date, a.alert_message as message, 
                   a.resolution_status as status, a.alert_type, a.severity,
                   CONCAT(p.first_name, ' ', p.last_name) as patient_name,
                   p.hn
            FROM Alerts a
            JOIN PatientProfiles p ON a.patient_id = p.patient_id
            WHERE a.resolution_status = ?
            ORDER BY a.created_at DESC
            LIMIT ?
        `, [status, limit]);
        
        res.json(alerts);
    } catch (error) {
        console.error('Error getting alerts:', error);
        res.status(500).json({ error: error.message });
    }
});

// ===========================================
// DASHBOARD AND ANALYTICS
// ===========================================

// Get dashboard statistics
app.get('/api/dashboard/stats', authDoctor, async (req, res) => {
  try {
    const doctorId = req.doctor.doctor_id;
    console.log(`📊 Loading dashboard stats for doctor: ${doctorId}`);

    const stats = {
      totalPatients: 0,
      todayAppointments: 0,
      pendingAlerts: 0,
      needFollowUp: 0,
      highIOPCount: 0,
      activeMedications: 0,
      recentTests: { total_tests: 0, oct_tests: 0, ctvf_tests: 0 }
    };

    // 1. นับผู้ป่วยทั้งหมดในระบบ (แก้ไข: ไม่กรองตาม doctor)
    try {
      const [totalPatients] = await pool.execute(
        `SELECT COUNT(*) as total FROM PatientProfiles`
      );
      stats.totalPatients = totalPatients[0]?.total || 0;
    } catch (error) {
      console.error('Error getting total patients:', error);
    }

    // 2. นัดหมายที่กำลังมาถึง 7 วันข้างหน้า (แก้ไข: ไม่กรองตาม doctor)
    try {
      const [todayAppointments] = await pool.execute(
        `SELECT COUNT(*) as total FROM Appointments 
         WHERE appointment_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 7 DAY)
         AND appointment_status IN ('scheduled', 'rescheduled')`
      );
      stats.todayAppointments = todayAppointments[0]?.total || 0;
    } catch (error) {
      console.error('Error getting upcoming appointments:', error);
    }

    // 3. การแจ้งเตือนที่ยังไม่ได้แก้ไข (แก้ไข: ไม่กรองตาม doctor)
    try {
      const [pendingAlerts] = await pool.execute(
        `SELECT COUNT(*) as total FROM Alerts 
         WHERE resolution_status = 'pending'`
      );
      stats.pendingAlerts = pendingAlerts[0]?.total || 0;
    } catch (error) {
      console.error('Error getting pending alerts:', error);
    }

    // 4. ผู้ป่วยที่ต้องติดตาม (แก้ไข: ไม่กรองตาม doctor)
    try {
      const [needFollowUp] = await pool.execute(
        `SELECT COUNT(DISTINCT p.patient_id) as total
         FROM PatientProfiles p
         LEFT JOIN PatientVisits pv ON p.patient_id = pv.patient_id 
           AND pv.visit_date >= DATE_SUB(CURDATE(), INTERVAL 90 DAY)
         WHERE pv.visit_id IS NULL`
      );
      stats.needFollowUp = needFollowUp[0]?.total || 0;
    } catch (error) {
      console.error('Error getting follow-up needed:', error);
      // ถ้าไม่มีตาราง PatientVisits ให้ใช้ค่า 0
      stats.needFollowUp = 0;
    }

    // 5. IOP สูงในเดือนที่แล้ว (แก้ไข: ไม่กรองตาม doctor)
    try {
      const [highIOPCount] = await pool.execute(
        `SELECT COUNT(*) as total FROM IOP_Measurements 
         WHERE measurement_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
           AND (left_eye_iop > 21 OR right_eye_iop > 21)`
      );
      stats.highIOPCount = highIOPCount[0]?.total || 0;
    } catch (error) {
      console.error('Error getting high IOP count:', error);
    }

    // 6. ยาที่กำลังใช้อยู่ (แก้ไข: ไม่กรองตาม doctor)
    try {
      const [activeMedications] = await pool.execute(
        `SELECT COUNT(*) as total FROM PatientMedications 
         WHERE status = 'active'`
      );
      stats.activeMedications = activeMedications[0]?.total || 0;
    } catch (error) {
      console.error('Error getting active medications:', error);
    }

    // 7. การตรวจพิเศษเดือนที่แล้ว (แก้ไข: ไม่กรองตาม doctor และแก้ alias)
    try {
      const [recentTests] = await pool.execute(`
            SELECT 
                COUNT(*) as total_tests,
                SUM(CASE WHEN test_type = 'OCT' THEN 1 ELSE 0 END) as oct_tests,
                SUM(CASE WHEN test_type = 'CTVF' THEN 1 ELSE 0 END) as ctvf_tests
            FROM SpecialEyeTests st
            WHERE st.test_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
        `);

      stats.recentTests = recentTests[0] || { total_tests: 0, oct_tests: 0, ctvf_tests: 0 };
    } catch (error) {
      console.error('Error getting recent tests:', error);
    }

    console.log(`📈 Dashboard stats loaded:`, stats);
    res.json(stats);

  } catch (error) {
    console.error('Error getting dashboard stats:', error);
    res.status(500).json({ error: error.message });
  }
});

// ===========================================
// ADHERENCE MONITORING SYSTEM
// ===========================================

// Create AdherenceAlerts table if not exists
const createAdherenceAlertsTable = async () => {
  try {
    await pool.execute(`
      CREATE TABLE IF NOT EXISTS AdherenceAlerts (
        alert_id VARCHAR(36) PRIMARY KEY,
        patient_id VARCHAR(36) NOT NULL,
        doctor_id VARCHAR(36) NOT NULL,
        prescription_id VARCHAR(36) NOT NULL,
        alert_date DATE NOT NULL,
        alert_type ENUM('missed_dose', 'late_dose', 'skipped_dose') NOT NULL,
        message TEXT NOT NULL,
        status ENUM('pending', 'resolved', 'ignored') DEFAULT 'pending',
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        resolved_at DATETIME NULL,
        resolution_notes TEXT NULL,
        INDEX idx_alert_patient (patient_id),
        INDEX idx_alert_doctor (doctor_id),
        INDEX idx_alert_status (status),
        FOREIGN KEY (patient_id) REFERENCES PatientProfiles(patient_id) ON DELETE CASCADE,
        FOREIGN KEY (doctor_id) REFERENCES DoctorProfiles(doctor_id),
        FOREIGN KEY (prescription_id) REFERENCES PatientMedications(prescription_id) ON DELETE CASCADE
      )
    `);
  } catch (error) {
    console.log('AdherenceAlerts table already exists or creation failed:', error.message);
  }
};

// Create PatientDailyAdherence table if not exists
const createPatientDailyAdherenceTable = async () => {
  try {
    await pool.execute(`
      CREATE TABLE IF NOT EXISTS PatientDailyAdherence (
        adherence_id VARCHAR(36) PRIMARY KEY,
        patient_id VARCHAR(36) NOT NULL,
        prescription_id VARCHAR(36) NOT NULL,
        adherence_date DATE NOT NULL,
        taken_status ENUM('taken', 'skipped', 'late') NOT NULL,
        recorded_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        notes TEXT NULL,
        INDEX idx_adherence_patient (patient_id),
        INDEX idx_adherence_prescription (prescription_id),
        INDEX idx_adherence_date (adherence_date),
        FOREIGN KEY (patient_id) REFERENCES PatientProfiles(patient_id) ON DELETE CASCADE,
        FOREIGN KEY (prescription_id) REFERENCES PatientMedications(prescription_id) ON DELETE CASCADE
      )
    `);
  } catch (error) {
    console.log('PatientDailyAdherence table already exists or creation failed:', error.message);
  }
};

// Initialize tables
createAdherenceAlertsTable();
createPatientDailyAdherenceTable();

// Manual adherence recording endpoint (for testing or manual entry)
app.post('/api/patients/:patientId/adherence', authDoctor, async (req, res) => {
  try {
    const patientId = req.params.patientId;
    const { prescriptionId, adherenceDate, takenStatus, notes } = req.body;

    // Verify patient access
    const [relationship] = await pool.execute(
      `SELECT relationship_id FROM DoctorPatientRelationships
       WHERE doctor_id = ? AND patient_id = ? AND status = 'active'`,
      [req.doctor.doctor_id, patientId]
    );

    if (relationship.length === 0) {
      return res.status(403).json({ error: 'Patient not under your care' });
    }

    const adherenceId = uuidv4();

    await pool.execute(
      `INSERT INTO PatientDailyAdherence (
        adherence_id, patient_id, prescription_id, adherence_date, taken_status, notes
      ) VALUES (?, ?, ?, ?, ?, ?)`,
      [adherenceId, patientId, prescriptionId, adherenceDate, takenStatus, notes]
    );

    res.status(201).json({ message: 'Adherence recorded successfully' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get adherence report for patient
app.get('/api/patients/:patientId/adherence', authDoctor, async (req, res) => {
  try {
    const patientId = req.params.patientId;
    const { startDate, endDate, prescriptionId } = req.query;

    // Verify patient access
    const [relationship] = await pool.execute(
      `SELECT relationship_id FROM DoctorPatientRelationships
       WHERE doctor_id = ? AND patient_id = ? AND status = 'active'`,
      [req.doctor.doctor_id, patientId]
    );

    if (relationship.length === 0) {
      return res.status(403).json({ error: 'Patient not under your care' });
    }

    let whereClause = 'WHERE pda.patient_id = ?';
    let queryParams = [patientId];

    if (startDate) {
      whereClause += ' AND pda.adherence_date >= ?';
      queryParams.push(startDate);
    }
    if (endDate) {
      whereClause += ' AND pda.adherence_date <= ?';
      queryParams.push(endDate);
    }
    if (prescriptionId) {
      whereClause += ' AND pda.prescription_id = ?';
      queryParams.push(prescriptionId);
    }

    const [adherenceRecords] = await pool.execute(
      `SELECT pda.*, m.name as medication_name, pm.frequency
       FROM PatientDailyAdherence pda
       JOIN PatientMedications pm ON pda.prescription_id = pm.prescription_id
       JOIN Medications m ON pm.medication_id = m.medication_id
       ${whereClause}
       ORDER BY pda.adherence_date DESC`,
      queryParams
    );

    // Calculate adherence statistics
    const [stats] = await pool.execute(
      `SELECT 
         COUNT(*) as total_records,
         SUM(CASE WHEN taken_status = 'taken' THEN 1 ELSE 0 END) as taken_count,
         SUM(CASE WHEN taken_status = 'skipped' THEN 1 ELSE 0 END) as skipped_count,
         SUM(CASE WHEN taken_status = 'late' THEN 1 ELSE 0 END) as late_count
       FROM PatientDailyAdherence pda
       ${whereClause}`,
      queryParams
    );

    const statistics = stats[0];
    if (statistics.total_records > 0) {
      statistics.adherence_rate = ((statistics.taken_count + statistics.late_count) / statistics.total_records * 100).toFixed(2);
      statistics.perfect_adherence_rate = (statistics.taken_count / statistics.total_records * 100).toFixed(2);
    }

    res.json({
      adherenceRecords,
      statistics
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ===========================================
// EMAIL NOTIFICATION SYSTEM
// ===========================================

// Nodemailer setup
const transporter = nodemailer.createTransport({
  host: process.env.EMAIL_HOST || 'smtp.ethereal.email',
  port: process.env.EMAIL_PORT || 587,
  secure: process.env.EMAIL_SECURE === 'true',
  auth: {
    user: process.env.EMAIL_USER || 'your_email@example.com',
    pass: process.env.EMAIL_PASS || 'your_email_password'
  },
  tls: {
    rejectUnauthorized: false
  }
});

// Send adherence alert email
const sendAdherenceAlertEmail = async (doctorEmail, patientName, medicationName) => {
  const mailOptions = {
    from: process.env.EMAIL_USER || '"Glaucoma System" <no-reply@example.com>',
    to: doctorEmail,
    subject: `⚠️ แจ้งเตือน: ผู้ป่วย ${patientName} ไม่ได้ใช้ยา ${medicationName} ตามกำหนด`,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h2 style="color: #d32f2f;">🔔 แจ้งเตือนการใช้ยา</h2>
        <p>เรียนคุณหมอ,</p>
        <div style="background-color: #fff3e0; padding: 15px; border-left: 4px solid #ff9800; margin: 15px 0;">
          <p><strong>ผู้ป่วย:</strong> ${patientName}</p>
          <p><strong>ยา:</strong> ${medicationName}</p>
          <p><strong>สถานะ:</strong> ไม่ได้ใช้ยาตามกำหนด</p>
          <p><strong>วันที่:</strong> ${new Date().toLocaleDateString('th-TH')}</p>
        </div>
        <p>กรุณาตรวจสอบข้อมูลการใช้ยาของผู้ป่วยและพิจารณาให้คำแนะนำเพิ่มเติม</p>
        <hr style="margin: 20px 0; border: none; border-top: 1px solid #eee;">
        <p style="font-size: 12px; color: #666;">
          ขอบคุณครับ/ค่ะ<br>
          ทีมงาน Glaucoma Management System
        </p>
      </div>
    `
  };

  try {
    await transporter.sendMail(mailOptions);
    console.log(`✅ Adherence alert email sent to ${doctorEmail} for patient ${patientName}`);
  } catch (error) {
    console.error('❌ Error sending adherence alert email:', error);
  }
};

// Send appointment reminder email
const sendAppointmentReminderEmail = async (doctorEmail, patientName, appointmentDate, appointmentTime) => {
  const mailOptions = {
    from: process.env.EMAIL_USER || '"Glaucoma System" <no-reply@example.com>',
    to: doctorEmail,
    subject: `📅 แจ้งเตือนนัดหมาย: ${patientName}`,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h2 style="color: #1976d2;">📅 แจ้งเตือนนัดหมายผู้ป่วย</h2>
        <p>เรียนคุณหมอ,</p>
        <div style="background-color: #e3f2fd; padding: 15px; border-left: 4px solid #2196f3; margin: 15px 0;">
          <p><strong>ผู้ป่วย:</strong> ${patientName}</p>
          <p><strong>วันที่นัด:</strong> ${appointmentDate}</p>
          <p><strong>เวลา:</strong> ${appointmentTime}</p>
        </div>
        <p>นี่คือการแจ้งเตือนนัดหมายผู้ป่วยของท่านในวันพรุ่งนี้</p>
        <hr style="margin: 20px 0; border: none; border-top: 1px solid #eee;">
        <p style="font-size: 12px; color: #666;">
          ขอบคุณครับ/ค่ะ<br>
          ทีมงาน Glaucoma Management System
        </p>
      </div>
    `
  };

  try {
    await transporter.sendMail(mailOptions);
    console.log(`✅ Appointment reminder sent to ${doctorEmail} for patient ${patientName}`);
  } catch (error) {
    console.error('❌ Error sending appointment reminder:', error);
  }
};

// ===========================================
// CRON JOBS FOR AUTOMATED MONITORING
// ===========================================

// Daily medication adherence check (runs at 3:00 AM)
cron.schedule('0 3 * * *', async () => {
  console.log('🔄 Running daily medication adherence check...');
  const connection = await pool.getConnection();
  try {
    // Get all active prescriptions
    const [prescriptions] = await connection.execute(
      `SELECT pm.prescription_id, pm.patient_id, pm.doctor_id, pm.frequency,
              m.name as medication_name, 
              CONCAT(p.first_name, ' ', p.last_name) as patient_name,
              u.email as doctor_email
       FROM PatientMedications pm
       JOIN Medications m ON pm.medication_id = m.medication_id
       JOIN PatientProfiles p ON pm.patient_id = p.patient_id
       JOIN DoctorProfiles d ON pm.doctor_id = d.doctor_id
       JOIN Users u ON d.doctor_id = u.user_id
       WHERE pm.status = 'active' 
         AND pm.start_date <= CURDATE() 
         AND (pm.end_date IS NULL OR pm.end_date >= CURDATE())`
    );

    const today = new Date().toISOString().split('T')[0];

    for (const prescription of prescriptions) {
      // Check if there's adherence record for today
      const [adherenceRecords] = await connection.execute(
        `SELECT adherence_id FROM PatientDailyAdherence
         WHERE patient_id = ? AND prescription_id = ? AND adherence_date = ? 
         AND taken_status = 'taken'`,
        [prescription.patient_id, prescription.prescription_id, today]
      );

      // If no 'taken' record for today, consider it missed
      if (adherenceRecords.length === 0) {
        // Check if alert already exists
        const [existingAlert] = await connection.execute(
          `SELECT alert_id FROM AdherenceAlerts
           WHERE patient_id = ? AND prescription_id = ? AND alert_date = ? 
           AND alert_type = 'missed_dose' AND status = 'pending'`,
          [prescription.patient_id, prescription.prescription_id, today]
        );

        if (existingAlert.length === 0) {
          // Create new alert
          const alertId = uuidv4();
          const alertMessage = `ผู้ป่วย ${prescription.patient_name} ไม่ได้ใช้ยา ${prescription.medication_name} ตามกำหนดในวันที่ ${today}`;
          
          await connection.execute(
            `INSERT INTO AdherenceAlerts (
              alert_id, patient_id, doctor_id, prescription_id, alert_date, 
              alert_type, message, status, created_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, 'pending', NOW())`,
            [alertId, prescription.patient_id, prescription.doctor_id, 
             prescription.prescription_id, today, 'missed_dose', alertMessage]
          );

          // Send email notification if configured
          if (process.env.EMAIL_USER && process.env.EMAIL_PASS && prescription.doctor_email) {
            await sendAdherenceAlertEmail(
              prescription.doctor_email,
              prescription.patient_name,
              prescription.medication_name
            );
          }

          console.log(`⚠️ Adherence alert created for patient ${prescription.patient_name}, medication ${prescription.medication_name}`);
        }
      }
    }
  } catch (error) {
    console.error('❌ Error during daily medication adherence check:', error);
  } finally {
    connection.release();
  }
});

// Daily appointment reminder (runs at 8:00 AM)
cron.schedule('0 8 * * *', async () => {
  console.log('🔄 Running daily appointment reminder check...');
  try {
    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);
    const tomorrowStr = tomorrow.toISOString().split('T')[0];

    const [appointments] = await pool.execute(
      `SELECT a.appointment_id, a.appointment_time,
              CONCAT(p.first_name, ' ', p.last_name) as patient_name,
              u.email as doctor_email
       FROM Appointments a
       JOIN PatientProfiles p ON a.patient_id = p.patient_id
       JOIN Users u ON a.doctor_id = u.user_id
       WHERE a.appointment_date = ? 
         AND a.appointment_status IN ('scheduled', 'rescheduled')`,
      [tomorrowStr]
    );

    for (const appointment of appointments) {
      if (appointment.doctor_email) {
        await sendAppointmentReminderEmail(
          appointment.doctor_email,
          appointment.patient_name,
          tomorrow.toLocaleDateString('th-TH'),
          appointment.appointment_time
        );
      }
    }

    console.log(`📅 Sent ${appointments.length} appointment reminders`);
  } catch (error) {
    console.error('❌ Error sending appointment reminders:', error);
  }
});

// ===========================================
// แก้ไข ALERT RESOLVE API
// ===========================================

app.put('/api/adherence-alerts/:alertId/resolve', authDoctor, async (req, res) => {
  try {
    const alertId = req.params.alertId;
    const { resolutionNotes } = req.body;
    const doctorId = req.doctor.doctor_id;

    console.log(`🔧 Resolving alert ${alertId} by doctor ${doctorId}`);

    // ตรวจสอบว่า alert นี้เป็นของผู้ป่วยที่อยู่ภายใต้การดูแลของหมอคนนี้
    const [alert] = await pool.execute(
      `SELECT a.alert_id FROM Alerts a
       JOIN DoctorPatientRelationships dpr ON a.patient_id = dpr.patient_id
       WHERE a.alert_id = ? AND dpr.doctor_id = ? AND dpr.status = 'active'`,
      [alertId, doctorId]
    );

    if (alert.length === 0) {
      return res.status(404).json({ error: 'Alert not found or not authorized to resolve' });
    }

    // อัปเดตสถานะของ alert
    await pool.execute(
      `UPDATE Alerts 
       SET resolution_status = 'resolved', 
           acknowledged = 1,
           acknowledged_by = ?,
           acknowledged_at = NOW(),
           resolution_notes = ?,
           resolved_at = NOW()
       WHERE alert_id = ?`,
      [doctorId, resolutionNotes || 'แก้ไขจาก Dashboard', alertId]
    );

    console.log(`✅ Alert ${alertId} resolved successfully`);
    res.json({ message: 'Alert resolved successfully' });

  } catch (error) {
    console.error('❌ Error resolving alert:', error);
    res.status(500).json({ error: 'ไม่สามารถแก้ไขการแจ้งเตือนได้: ' + error.message });
  }
});

// ===========================================
// เพิ่ม DEBUG ENDPOINTS
// ===========================================

// ตรวจสอบตารางที่มีในฐานข้อมูล
app.get('/api/debug/tables', authDoctor, async (req, res) => {
  try {
    const [tables] = await pool.execute(
      `SELECT TABLE_NAME 
       FROM INFORMATION_SCHEMA.TABLES 
       WHERE TABLE_SCHEMA = DATABASE() 
       ORDER BY TABLE_NAME`
    );
    
    const tableList = tables.map(t => t.TABLE_NAME);
    res.json({ 
      status: 'success',
      database: process.env.DB_NAME || 'glaucoma_management_system',
      tables: tableList,
      count: tableList.length
    });
  } catch (error) {
    res.status(500).json({ 
      status: 'error', 
      message: error.message 
    });
  }
});

// ตรวจสอบข้อมูลพื้นฐาน
app.get('/api/debug/data-summary', authDoctor, async (req, res) => {
  try {
    const doctorId = req.doctor.doctor_id;
    const summary = {};

    // นับข้อมูลในแต่ละตาราง
    const tables = [
      'PatientProfiles',
      'DoctorProfiles', 
      'DoctorPatientRelationships',
      'Appointments',
      'Alerts',
      'IOP_Measurements',
      'PatientMedications',
      'SpecialEyeTests'
    ];

    for (const table of tables) {
      try {
        const [count] = await pool.execute(`SELECT COUNT(*) as total FROM ${table}`);
        summary[table] = count[0].total;
      } catch (error) {
        summary[table] = `Error: ${error.message}`;
      }
    }

    // ข้อมูลเฉพาะของหมอคนนี้
    try {
      const [doctorPatients] = await pool.execute(
        `SELECT COUNT(*) as total FROM DoctorPatientRelationships 
         WHERE doctor_id = ? AND status = 'active'`,
        [doctorId]
      );
      summary.doctorPatients = doctorPatients[0].total;
    } catch (error) {
      summary.doctorPatients = `Error: ${error.message}`;
    }

    res.json({
      status: 'success',
      doctor_id: doctorId,
      summary
    });

  } catch (error) {
    res.status(500).json({ 
      status: 'error', 
      message: error.message 
    });
  }
});

// ทดสอบการเชื่อมต่อ
app.get('/api/test-connection', authDoctor, async (req, res) => {
  try {
    const [result] = await pool.execute('SELECT NOW() as current_time, DATABASE() as database_name');
    res.json({ 
      status: 'success', 
      message: 'Database connection OK',
      server_time: result[0].current_time,
      database: result[0].database_name,
      doctor: {
        id: req.doctor.doctor_id,
        name: `${req.doctor.first_name} ${req.doctor.last_name}`
      }
    });
  } catch (error) {
    res.status(500).json({ 
      status: 'error', 
      message: error.message 
    });
  }
});

console.log('✅ Dashboard APIs updated to use existing tables');
console.log('🔧 Available debug endpoints:');
console.log('   GET /api/test-connection');
console.log('   GET /api/debug/tables');
console.log('   GET /api/debug/data-summary');

// ===========================================
// ERROR HANDLING MIDDLEWARE
// ===========================================

// Global error handler
app.use((error, req, res, next) => {
  console.error('Global error handler:', error);
  
  if (error instanceof multer.MulterError) {
    if (error.code === 'LIMIT_FILE_SIZE') {
      return res.status(400).json({ error: 'File too large. Maximum size is 10MB.' });
    }
    return res.status(400).json({ error: error.message });
  }
  
  res.status(500).json({ 
    error: 'Internal server error',
    message: process.env.NODE_ENV === 'development' ? error.message : 'Something went wrong'
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Endpoint not found' });
});

// ===========================================
// SERVER STARTUP
// ===========================================

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`
🚀 Doctor API Server is running on port ${PORT}
📊 Database: ${process.env.DB_NAME || 'glaucoma_management_system'}
🌐 Environment: ${process.env.NODE_ENV || 'development'}
📧 Email notifications: ${process.env.EMAIL_USER ? 'Enabled' : 'Disabled'}
⏰ Automated monitoring: Active
  `);
});

// Graceful shutdown
process.on('SIGTERM', async () => {
  console.log('🛑 Received SIGTERM, shutting down gracefully...');
  await pool.end();
  process.exit(0);
});

process.on('SIGINT', async () => {
  console.log('🛑 Received SIGINT, shutting down gracefully...');
  await pool.end();
  process.exit(0);
});

module.exports = app;