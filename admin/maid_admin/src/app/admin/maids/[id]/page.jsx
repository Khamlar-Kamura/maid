"use client";
import { useEffect, useState, useRef } from "react";
import { useParams, useRouter } from "next/navigation";
import { getMaid, updateMaid, deleteMaid, uploadProfileImage } from "../../api";
import styles from './page.module.css';

 // './' หมายถึงโฟลเดอร์เดียวกัน
export default function MaidProfile() {
  const { id } = useParams();
  const router = useRouter();

  // State เดิม
  const [maid, setMaid] = useState(null);
  const [formState, setFormState] = useState(null);
  const [isEditing, setIsEditing] = useState(false);
    const [isDeleteModalOpen, setIsDeleteModalOpen] = useState(false);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [message, setMessage] = useState("");


  // State ใหม่สำหรับอัปโหลดรูป
  const [selectedFile, setSelectedFile] = useState(null);
  const [previewUrl, setPreviewUrl] = useState(null);
  const [isUploading, setIsUploading] = useState(false);
  const fileInputRef = useRef(null);
  

  useEffect(() => {
    if (id) {
      setLoading(true);
      getMaid(id)
        .then((data) => {
          setMaid(data);
          // ขยาย formState ให้รองรับข้อมูลเวลา
          setFormState({
            ...data,
            start_time: data.available_time?.start || "",
            end_time: data.available_time?.end || "",
          });
          if (data.profile_image) {
            setPreviewUrl(`http://localhost:5000${data.profile_image}`);
          }
          setError("");
        })
        .catch((err) => {
          setError("ไม่สามารถโหลดข้อมูลแม่บ้านได้ หรืออาจไม่มีข้อมูลนี้");
          console.error(err);
        })
        .finally(() => setLoading(false));
    }
  }, [id]);
const handleClosePopup = () => {
    setMessage('');
    setError('');
  };
  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    setFormState({
      ...formState,
      [name]: type === "checkbox" ? checked : value,
    });
  };

  const handleUpdate = async (e) => {
    e.preventDefault();
    setMessage("");
    setError("");

    // --- ส่วนที่แก้ไข ---
    const payload = {
      ...formState,
      skills:
        typeof formState.skills === "string"
          ? formState.skills
              .split(",")
              .map((s) => s.trim())
              .filter(Boolean)
          : formState.skills,
      available_days:
        typeof formState.available_days === "string"
          ? formState.available_days
              .split(",")
              .map((d) => d.trim())
              .filter(Boolean)
          : formState.available_days,
      preferred_work_type:
        typeof formState.preferred_work_type === "string"
          ? formState.preferred_work_type
              .split(",")
              .map((w) => w.trim())
              .filter(Boolean)
          : formState.preferred_work_type,
      age: Number(formState.age) || null,
      expected_salary: Number(formState.expected_salary) || 0,

      // เพิ่ม location เข้าไปใน payload
      location: {
        lat: Number(formState.lat) || null,
        lng: Number(formState.lng) || null,
      },

      available_time: {
        start: formState.start_time,
        end: formState.end_time,
      },
    };

    // ลบ key ที่ไม่จำเป็นออก
    delete payload.lat;
    delete payload.lng;
    delete payload.start_time;
    delete payload.end_time;

    try {
      const updatedData = await updateMaid(id, payload);
      setMaid(updatedData);
      setMessage("ບັນທຶກຂໍ້ມູນສຳເລັດ!");
      setIsEditing(false);
    } catch (err) {
      setError("ເກີດການຜິດພາດໃນການອັບເດດຂໍ້ມູນ");
      console.error(err);
    }
  };

const handleDelete = () => {
    setIsDeleteModalOpen(true);
  };
const handleConfirmDelete = async () => {
    if (maid) {
      try {
        await deleteMaid(id);
        setIsDeleteModalOpen(false); // ปิดหน้าต่างยืนยัน
        
        // แสดง Popup ว่าลบสำเร็จ
        setMessage('ລົບຂໍ້ມູນສຳເລັດ!'); 

        // หน่วงเวลา 1.5 วินาที แล้วค่อยกลับไปหน้า Dashboard
        setTimeout(() => {
          router.push('/admin/dashboard');
        }, 1500);

      } catch (err) {
        setError('ເກີດຂໍ້ຜິດພາດໃນການລົບຂໍ້ມູນ');
        console.error(err);
        setIsDeleteModalOpen(false);
      }
    }
  };
  const handleFileChange = (e) => {
    const file = e.target.files[0];
    if (file) {
      setSelectedFile(file);
      const newPreviewUrl = URL.createObjectURL(file);
      setPreviewUrl(newPreviewUrl);
    }
  };

  const handleConfirmUpload = async () => {
    if (!selectedFile) {
      setError("ກະລຸນາເລືອກໄຟລ໌ຮູບພາບ");
      return;
    }
    setIsUploading(true);
    setError("");
    setMessage("");
    try {
      const result = await uploadProfileImage(id, selectedFile);
      setMaid((prevMaid) => ({
        ...prevMaid,
        profile_image: result.profile_image,
      }));
      setMessage("ອັບໂຫຼດຮູບພາບສຳເລັດ!");
      setSelectedFile(null);
    } catch (err) {
      setError("ເກີດຂໍ້ຜິດພາດໃນການອັບໂຫຼດຮູບພາບ");
    } finally {
      setIsUploading(false);
    }
  };

  if (loading)
    return <div className="p-8 text-center font-bold">ກຳລັງໂຫຼດຂໍ້ມູນ...</div>;

  return (
       <div className="max-w-5xl mx-auto p-6 md:p-8 font-[Inter]">
      {/* --- JSX ที่แก้ไขแล้วสำหรับ Popup --- */}
      {(message || error) && (
        <div className={styles.popupOverlay}>
          <div 
            className={`${styles.popup} ${message ? styles.popupSuccess : styles.popupError}`} 
            style={{ flexDirection: 'column', alignItems: 'center', gap: '1rem', padding: '1rem' }}
          >
            <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
              <span className={styles.popupIcon}>{message ? '✅' : '❌'}</span>
              <span className={styles.popupMessage}>{message || error}</span>
            </div>
            <button 
              onClick={handleClosePopup} 
              className="px-8 py-1 bg-white rounded-full shadow-md text-sm font-semibold text-gray-700 hover:bg-gray-100"
            >
              OK
            </button>
          </div>
        </div>
      )}

    {/* --- JSX ใหม่สำหรับหน้าต่างยืนยันการลบ --- */}
    {isDeleteModalOpen && (
      <div className={styles.popupOverlay}>
        <div className={`${styles.popup} bg-white border-l-4 border-yellow-400`}>
          <div className="text-center">
            <h4 className="font-bold text-lg text-gray-800">ຢືນຢັນການລົບ</h4>
            <p className="my-2 text-gray-600">ເຈົ້າຕ້ອງການລົບຂໍ້ມູນຂອງ {maid?.full_name} ແທ້ຫຼືບໍ່?</p>
            <div className="flex justify-center gap-4 mt-4">
              <button onClick={() => setIsDeleteModalOpen(false)} className="px-6 py-2 bg-gray-300 text-gray-800 rounded-lg hover:bg-gray-400">ยกเลิก</button>
              <button onClick={handleConfirmDelete} className="px-6 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700">ยืนยัน</button>
            </div>
          </div>
        </div>
      </div>
    )}





      <button
        onClick={() => router.back()}
        className="mb-6 text-blue-600 hover:underline"
      >
        ← กลับไปหน้ารายการ
      </button>

      {message && (
        <div className="mb-4 p-3 text-center bg-green-100 text-green-800 border border-green-300 rounded-lg">
          {message}
        </div>
      )}
      {error && (
        <div className="mb-4 p-3 text-center bg-red-100 text-red-800 border border-red-300 rounded-lg">
          {error}
        </div>
      )}

      <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
        {/* ส่วนที่ 1: รูปโปรไฟล์และปุ่มอัปโหลด */}
        <div className="md:col-span-1 flex flex-col items-center pt-4">
          <img
            src={previewUrl || "/default-avatar.png"}
            alt="Profile"
            className="w-48 h-48 rounded-full object-cover border-4 border-gray-200 mb-4"
            onError={(e) => {
              e.target.onerror = null;
              e.target.src = "/default-avatar.png";
            }}
          />
          <input
            type="file"
            ref={fileInputRef}
            onChange={handleFileChange}
            className="hidden"
            accept="image/png, image/jpeg"
          />
          <button
            onClick={() => fileInputRef.current.click()}
            className="w-full px-4 py-2 bg-blue-500 text-white font-semibold rounded-lg shadow-md hover:bg-blue-600 mb-2"
          >
            เลือกรูปภาพ
          </button>
          {selectedFile && (
            <button
  onClick={handleConfirmUpload}
  disabled={isUploading}
  className="w-full px-4 py-2 bg-green-500 text-white font-semibold rounded-lg shadow-md hover:bg-green-600 disabled:bg-gray-400"
  style={{ fontFamily: "'Noto Sans Lao Condensed', sans-serif" }}
>
  {isUploading ? "ກຳລັງອັບໂຫຼດ..." : "ຢືນຢັນການອັບໂຫຼດ"}
</button>
          )}
        </div>

        {/* ส่วนที่ 2: ข้อมูลโปรไฟล์และฟอร์มแก้ไข */}
        <div className="md:col-span-2">
          <div className="border-b pb-4 mb-6 flex justify-between items-center">
            <h2
  className="text-3xl font-bold text-gray-800"
  style={{ fontFamily: "'Noto Sans Lao Condensed', sans-serif" }}
>
  ໂປຣໄຟລ: {maid?.full_name}
</h2>
            {!isEditing && maid && (
              <div className="flex gap-2">
                <button
                  onClick={() => setIsEditing(true)}
                  className="px-4 py-2 bg-yellow-500 text-white font-semibold rounded-lg shadow-md hover:bg-yellow-600"
                >
                  แก้ไข
                </button>
                <button
                  onClick={handleDelete}
                  className="px-4 py-2 bg-red-600 text-white font-semibold rounded-lg shadow-md hover:bg-red-700"
                >
                  ลบ
                </button>
              </div>
            )}
          </div>

          {isEditing ? (
            // ==================== โหมดแก้ไข (Form) ====================
            // ==================== โหมดแก้ไข (Form) ====================
            <form onSubmit={handleUpdate} className="space-y-4">
              <div className="max-w-5xl mx-auto p-6 md:p-8 font-sans">
                <input
                  type="text"
                  name="full_name"
                  value={formState?.full_name || ""}
                  onChange={handleChange}
                  placeholder="ຊື່-ນາມສະກຸນ"
                  className="p-3 border border-gray-300 rounded-md"
                />
                <input
                  type="text"
                  name="phone_number"
                  value={formState?.phone_number || ""}
                  onChange={handleChange}
                  placeholder="เบอร์โทร"
                  className="p-3 border border-gray-300 rounded-md"
                />
                <input
                  type="email"
                  name="email"
                  value={formState?.email || ""}
                  onChange={handleChange}
                  placeholder="ອີເມລ"
                  className="p-3 border border-gray-300 rounded-md"
                />
                <input
                  type="text"
                  name="address"
                  value={formState?.address || ""}
                  onChange={handleChange}
                  placeholder="ที่อยู่"
                  className="p-3 border border-gray-300 rounded-md"
                />
                <input
                  type="number"
                  name="age"
                  value={formState?.age || ""}
                  onChange={handleChange}
                  placeholder="อายุ"
                  className="p-3 border border-gray-300 rounded-md"
                />
                <select
                  name="gender"
                  value={formState?.gender || "หญิง"}
                  onChange={handleChange}
                  className="p-3 border border-gray-300 rounded-md bg-white"
                >
                  <option value="หญิง">หญิง</option>
                  <option value="ชาย">ชาย</option>
                  <option value="อื่นๆ">อื่นๆ</option>
                </select>
                <input
                  type="text"
                  name="skills"
                  value={
                    Array.isArray(formState?.skills)
                      ? formState.skills.join(", ")
                      : formState?.skills || ""
                  }
                  onChange={handleChange}
                  placeholder="ทักษะ (คั่นด้วย ,)"
                  className="p-3 border border-gray-300 rounded-md"
                />
                <input
                  type="text"
                  name="available_days"
                  value={
                    Array.isArray(formState?.available_days)
                      ? formState.available_days.join(", ")
                      : formState?.available_days || ""
                  }
                  onChange={handleChange}
                  placeholder="วันที่ว่าง (คั่นด้วย ,)"
                  className="p-3 border border-gray-300 rounded-md"
                />
                <input
                  type="text"
                  name="preferred_work_type"
                  value={
                    Array.isArray(formState?.preferred_work_type)
                      ? formState.preferred_work_type.join(", ")
                      : formState?.preferred_work_type || ""
                  }
                  onChange={handleChange}
                  placeholder="ประเภทงานที่ถนัด (คั่นด้วย ,)"
                  className="p-3 border border-gray-300 rounded-md"
                />
                <input
                  type="number"
                  name="expected_salary"
                  value={formState?.expected_salary || ""}
                  onChange={handleChange}
                  placeholder="เงินเดือนที่ต้องการ"
                  className="p-3 border border-gray-300 rounded-md"
                />
                <div>
                  <label className="text-sm font-medium text-gray-700">
                    เวลาเริ่มงาน
                  </label>
                  <input
                    type="time"
                    name="start_time"
                    value={formState?.start_time || ""}
                    onChange={handleChange}
                    className="w-full p-2 border border-gray-300 rounded-md"
                  />
                </div>
                <div>
                  <label className="text-sm font-medium text-gray-700">
                    เวลาเลิกงาน
                  </label>
                  <input
                    type="time"
                    name="end_time"
                    value={formState?.end_time || ""}
                    onChange={handleChange}
                    className="w-full p-2 border border-gray-300 rounded-md"
                  />
                </div>

                {/* --- เพิ่ม Dropdown สำหรับ Status ที่นี่ --- */}
                <div className="md:col-span-2">
                  <label className="block text-sm font-medium text-gray-700">
                    สถานะการทำงาน
                  </label>
                  <select
                    name="status"
                    value={formState?.status || ""}
                    onChange={handleChange}
                    className="w-full p-3 border border-gray-300 rounded-md bg-white"
                  >
                    <option value="ว่าง">ว่าง (Available)</option>
                    <option value="กำลังทำงาน">กำลังทำงาน (On a Job)</option>
                    <option value="ลาพัก">ลาพัก (On Leave)</option>
                    <option value="รอตรวจสอบ">
                      รอตรวจสอบ (Pending Review)
                    </option>
                    <option value="ระงับการใช้งาน">
                      ระงับการใช้งาน (Suspended)
                    </option>
                  </select>
                </div>
              </div>

              <div className="flex justify-end gap-4 mt-6">
                <button
                  type="button"
                  onClick={() => setIsEditing(false)}
                  className="px-6 py-2 bg-gray-300 text-gray-800 font-semibold rounded-lg hover:bg-gray-400"
                >
                  ยกเลิก
                </button>
                <button
                  type="submit"
                  className="px-6 py-2 bg-blue-600 text-white font-semibold rounded-lg shadow-md hover:bg-blue-700"
                >
                  บันทึก
                </button>
              </div>
            </form>
          ) : (
            // ==================== โหมดแสดงผล (View) ====================
            maid && (
              <div className="space-y-3">
                <p>
                  <strong>เบอร์โทร:</strong> {maid.phone_number}
                </p>
                <p>
                  <strong>อีเมล:</strong> {maid.email || "-"}
                </p>
                <p>
                  <strong>ที่อยู่:</strong> {maid.address || "-"}
                </p>
                <p>
                  <strong>อายุ:</strong> {maid.age || "-"}
                </p>
                <p>
                  <strong>เพศ:</strong> {maid.gender || "-"}
                </p>
                <p>
                  <strong>ทักษะ:</strong> {(maid.skills || []).join(", ")}
                </p>
                <p>
                  <strong>วันที่ว่าง:</strong>{" "}
                  {(maid.available_days || []).join(", ")}
                </p>
                <p>
                  <strong>เวลาทำงาน:</strong>{" "}
                  {maid.available_time?.start && maid.available_time?.end
                    ? `${maid.available_time.start} - ${maid.available_time.end}`
                    : "-"}
                </p>
                <p>
                  <strong>ประเภทงานที่ถนัด:</strong>{" "}
                  {(maid.preferred_work_type || []).join(", ")}
                </p>

                <p>
                  <strong>เงินเดือนที่ต้องการ:</strong>{" "}
                  {maid.expected_salary?.toLocaleString()}
                </p>
                <p>
                  <strong>สถานะ:</strong>
                  <span className="ml-2 px-3 py-1 text-sm font-semibol rounded-full bg-blue-100 text-blue-800">
                    {maid.status}
                  </span>
                </p>
              </div>
            )
          )}
        </div>
        </div>
    </div>
  );
}
