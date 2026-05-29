const mongoose = require('mongoose');

const uri = 'mongodb+srv://murugannagaraja781_db_user:NewLife2025@cluster0.tp2gekn.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0';

// Define User Schema briefly just for this script
const userSchema = new mongoose.Schema({
  email: String,
  role: String
}, { strict: false });

const User = mongoose.model('User', userSchema);

async function run() {
  try {
    await mongoose.connect(uri);
    console.log('Connected to MongoDB');

    // Hack: Make the shared test user an admin so they can test the dashboard without pushing code!
    const result = await User.updateOne(
      { uid: 'test-user-uid' },
      { $set: { role: 'superadmin' } }
    );
    
    console.log('Update Result:', result);
    
    // Also explicitly make murugannagaraja781@gmail.com superadmin just in case
    await User.updateOne(
      { email: 'murugannagaraja781@gmail.com' },
      { $set: { role: 'superadmin' } },
      { upsert: true }
    );
    
  } catch (err) {
    console.error(err);
  } finally {
    mongoose.disconnect();
  }
}

run();
