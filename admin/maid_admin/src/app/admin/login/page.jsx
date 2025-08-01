'use client';
import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { adminLogin } from '../api';
import styles from './login.module.css';

export default function AdminLogin() {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const router = useRouter();

  const handleSubmit = async (e) => {
    e.preventDefault();
    const ok = await adminLogin(username, password);
    if (ok) {
      localStorage.setItem('admin', '1');
      router.push('/admin/dashboard');
    } else {
      setError('Login failed');
    }
  };

  return (
    <div className={styles.loginContainer}>
      <form className={styles.loginForm} onSubmit={handleSubmit}>
        <h2>Admin Login</h2>
        <input
          className={styles.loginInput}
          value={username}
          onChange={e => setUsername(e.target.value)}
          placeholder="Username"
          required
        />
        <input
          className={styles.loginInput}
          type="password"
          value={password}
          onChange={e => setPassword(e.target.value)}
          placeholder="Password"
          required
        />
        <button className={styles.loginBtn} type="submit">Login</button>
        {error && <div className={styles.loginError}>{error}</div>}
      </form>
    </div>
  );
}