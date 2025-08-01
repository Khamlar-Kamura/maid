const API = 'http://172.20.10.2:5000/admin';
const MAID_API = 'http://172.20.10.2:5000/maids'; // Backend API server

export async function adminLogin(username, password) {
  const res = await fetch(`${API}/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ username, password }),
    cache: 'no-store'
  });
  if (!res.ok) {
    const errorText = await res.text();
    console.error(`Admin Login Failed: ${res.status} ${res.statusText}`, errorText);
    throw new Error('Login failed');
  }
  return res.ok;
}

// === Functions for Maids ===

export async function getMaids(page, limit, searchValue) {
  try {
    const res = await fetch(`${MAID_API}?page=${page}&limit=${limit}&search=${searchValue}`);
    if (!res.ok) {
      const errorBody = await res.text();
      console.error(`Error fetching maids: ${res.status} ${res.statusText}`, errorBody);
      throw new Error(`Failed to fetch maids: ${res.status}`);
    }
    return res.json();
  } catch (error) {
    console.error('Network or other error fetching maids:', error);
    throw error;
  }
}

// ฟังก์ชันนี้รับ id (ซึ่งคือ maid_id) แล้วส่งไปที่ .../maids/:id
export async function getMaid(id) {
  try {
    const res = await fetch(`${MAID_API}/${id}`, { cache: 'no-store' });
    if (!res.ok) {
      const errorBody = await res.text();
      console.error(`Error fetching maid with id ${id}: ${res.status} ${res.statusText}`, errorBody);
      throw new Error(`Failed to fetch maid data: ${res.status}`);
    }
    return res.json();
  } catch (error) {
    console.error('Network or other error fetching single maid:', error);
    throw error;
  }
}

export async function addMaid(data) {
  try {
    const res = await fetch(MAID_API, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data),
      cache: 'no-store'
    });
    if (!res.ok) {
      const errorBody = await res.text();
      console.error(`Error adding maid: ${res.status} ${res.statusText}`, errorBody);
      throw res;
    }
    return res.json();
  } catch (error) {
    console.error('Network or other error during addMaid:', error);
    if (!(error instanceof Response)) {
      throw new Error('Network error or unexpected problem adding maid.');
    }
    throw error;
  }
}

// ฟังก์ชันนี้รับ id (ซึ่งคือ maid_id) แล้วส่งไปที่ .../maids/:id เพื่ออัปเดต
export async function updateMaid(id, data) {
  try {
    const res = await fetch(`${MAID_API}/${id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data),
      cache: 'no-store'
    });
    if (!res.ok) {
      const errorBody = await res.text();
      console.error(`Error updating maid: ${res.status} ${res.statusText}`, errorBody);
      throw res;
    }
    return res.json();
  } catch (error) {
    console.error('Network or other error during updateMaid:', error);
    if (!(error instanceof Response)) {
      throw new Error('Network error or unexpected problem updating maid.');
    }
    throw error;
  }
}

// ฟังก์ชันนี้รับ id (ซึ่งคือ maid_id) แล้วส่งไปที่ .../maids/:id เพื่อลบ
export async function deleteMaid(id) {
  try {
    const res = await fetch(`${MAID_API}/${id}`, {
      method: 'DELETE',
      cache: 'no-store'
    });
    if (!res.ok) {
      const errorBody = await res.text();
      console.error(`Error deleting maid: ${res.status} ${res.statusText}`, errorBody);
      throw res;
    }
    return res.json();
  } catch (error) {
    console.error('Network or other error during deleteMaid:', error);
    if (!(error instanceof Response)) {
      throw new Error('Network error or unexpected problem deleting maid.');
    }
    throw error;
  }
}

export async function getMaidReviews(id) {
  try {
    const res = await fetch(`${MAID_API}/${id}/reviews`, { cache: 'no-store' });
    if (!res.ok) {
      const errorBody = await res.text();
      console.error(`Error fetching maid reviews: ${res.status} ${res.statusText}`, errorBody);
      throw new Error(`Failed to fetch maid reviews: ${res.status}`);
    }
    return res.json();
  } catch (error) {
    console.error('Network or other error fetching reviews:', error);
    throw error;
  }
}
// เพิ่มฟังก์ชันนี้เข้าไปในไฟล์ api.js ของคุณ

export async function uploadProfileImage(maidId, file) {
  const formData = new FormData();
  formData.append('profile_image', file); // 'profile_image' ต้องตรงกับที่ตั้งค่าใน multer ของ backend

  try {
    const res = await fetch(`${MAID_API}/${maidId}/profile-image`, {
      method: 'POST',
      body: formData,
      // ไม่ต้องใส่ 'Content-Type' header, browser จะจัดการให้เองเมื่อส่ง FormData
    });

    if (!res.ok) {
      const errorBody = await res.text();
      console.error(`Error uploading image: ${res.status} ${res.statusText}`, errorBody);
      throw new Error('Image upload failed');
    }
    return res.json();
  } catch (error) {
    console.error('Network or other error during image upload:', error);
    throw error;
  }
}