const http = require('https');

const API_KEY = 'AIzaSyBDMw3LxDGy3wknc6Krc2BoHw8VHMgW0_c';
const EMAIL = 'admin2@lms.com';
const PASSWORD = 'password123';
const NAME = 'Admin User';

async function createFirebaseUser() {
    console.log(`Attempting to create Firebase account for ${EMAIL}...`);
    
    const body = JSON.stringify({
        email: EMAIL,
        password: PASSWORD,
        returnSecureToken: true
    });

    return new Promise((resolve, reject) => {
        const req = http.request(`https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${API_KEY}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' }
        }, (res) => {
            let data = '';
            res.on('data', chunk => data += chunk);
            res.on('end', () => {
                const parsed = JSON.parse(data);
                if (parsed.error && parsed.error.message === 'EMAIL_EXISTS') {
                    console.log('Account already exists! Attempting login to get token...');
                    loginFirebaseUser().then(resolve).catch(reject);
                } else if (parsed.error) {
                    reject(parsed.error.message);
                } else {
                    console.log('Firebase account created successfully!');
                    resolve(parsed.idToken);
                }
            });
        });
        req.on('error', reject);
        req.write(body);
        req.end();
    });
}

async function loginFirebaseUser() {
    const body = JSON.stringify({
        email: EMAIL,
        password: PASSWORD,
        returnSecureToken: true
    });

    return new Promise((resolve, reject) => {
        const req = http.request(`https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${API_KEY}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' }
        }, (res) => {
            let data = '';
            res.on('data', chunk => data += chunk);
            res.on('end', () => {
                const parsed = JSON.parse(data);
                if (parsed.error) {
                    reject(parsed.error.message);
                } else {
                    console.log('Logged in successfully!');
                    resolve(parsed.idToken);
                }
            });
        });
        req.on('error', reject);
        req.write(body);
        req.end();
    });
}

async function syncToRender(token) {
    console.log('Syncing user to Render backend...');
    const body = JSON.stringify({
        email: EMAIL,
        name: NAME,
        role: 'admin'
    });

    return new Promise((resolve, reject) => {
        const req = http.request('https://lms-bzuj.onrender.com/api/users/sync', {
            method: 'POST',
            headers: { 
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${token}`
            }
        }, (res) => {
            let data = '';
            res.on('data', chunk => data += chunk);
            res.on('end', () => {
                console.log('Render backend sync complete! Status:', res.statusCode);
                console.log('Response:', data);
                resolve();
            });
        });
        req.on('error', reject);
        req.write(body);
        req.end();
    });
}

async function main() {
    try {
        const token = await createFirebaseUser();
        await syncToRender(token);
        console.log(`\n✅ ALL DONE! You can now log into the app with:\nEmail: ${EMAIL}\nPassword: ${PASSWORD}`);
    } catch (e) {
        console.error('Error:', e);
    }
}

main();
