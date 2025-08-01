"use client";
import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { getMaids, addMaid } from "../api";
import styles from "./MaidManage.module.css";

export default function MaidManage() {
  const [maids, setMaids] = useState([]);
  const [form, setForm] = useState({
    full_name: "",
    phone_number: "",
    email: "",
    address: "",
    age: "",
    gender: "ຍິງ", // ค่าเริ่มต้น
    skills: "",
    available_days: "",
    expected_salary: "",
    preferred_work_type: "",
    lat: "",
    lng: "",
    start_time: "",
    end_time: "",
  });
  const [message, setMessage] = useState("");
  const [messageType, setMessageType] = useState("");
  const [search, setSearch] = useState("");
  const [currentPage, setCurrentPage] = useState(1); // <--- เพิ่ม
  const [totalPages, setTotalPages] = useState(1); // <--- เพิ่ม
  const [totalMaids, setTotalMaids] = useState(0);
  const router = useRouter();
  useEffect(() => {
    fetchMaids(1, search); // รีเซ็ตไปหน้า 1 ทุกครั้งที่ค้นหา
  }, [search]);

  const fetchMaids = async (page = 1, searchValue = "") => {
    try {
      const data = await getMaids(page, 10, searchValue); // ต้องแก้ getMaids ให้รับ search ด้วย
      setMaids(Array.isArray(data.maids) ? data.maids : []);
      setCurrentPage(page);
      setTotalPages(data.totalPages);
      setTotalMaids(data.totalMaids);
    } catch (err) {
      setMessage("เกิดข้อผิดพลาดในการดึงข้อมูลแม่บ้าน");
      setMessageType("error");
    }
  };

  // --- เพิ่มฟังก์ชันนี้เข้าไป ---
  const handleClosePopup = () => {
    setMessage("");
    setMessageType("");
  };
  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    setForm({ ...form, [name]: type === "checkbox" ? checked : value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!form.full_name.trim() || !form.phone_number.trim()) {
      setMessage("กรุณากรอกชื่อและเบอร์โทรศัพท์");
      setMessageType("error");
      return;
    }

    const payload = {
      ...form,
      skills: form.skills
        .split(",")
        .map((s) => s.trim())
        .filter(Boolean),
      available_days: form.available_days
        .split(",")
        .map((d) => d.trim())
        .filter(Boolean),
      preferred_work_type: form.preferred_work_type
        .split(",")
        .map((s) => s.trim())
        .filter(Boolean),
      expected_salary: Number(form.expected_salary) || 0,
      age: Number(form.age) || null,
      location: {
        lat: Number(form.lat) || null,
        lng: Number(form.lng) || null,
      },
      available_time: {
        start: form.start_time,
        end: form.end_time,
      },
    };
    // ลบ key ที่ไม่จำเป็นออกก่อนส่ง
    delete payload.lat;
    delete payload.lng;
    delete payload.start_time;
    delete payload.end_time;

    try {
      await addMaid(payload);
      setMessage("เพิ่มแม่บ้านสำเร็จ");
      setMessageType("success");
      // Reset form to initial state
      setForm({
        full_name: "",
        phone_number: "",
        email: "",
        address: "",
        age: "",
        gender: ",ຍິງ",
        skills: "",
        available_days: "",
        expected_salary: "",
        preferred_work_type: "",
        lat: "",
        lng: "",
        start_time: "",
        end_time: "",
        is_active: true,
      });
      fetchMaids();
    } catch (err) {
      setMessage("เกิดข้อผิดพลาดในการบันทึกข้อมูลแม่บ้าน");
      setMessageType("error");
    }
  };
  const filteredMaids = maids.filter((maid) => {
    const searchLower = search.toLowerCase();

    // สร้างข้อความรวมของข้อมูลที่ต้องการให้ค้นหาได้
    const searchableContent = [
      maid.full_name,
      maid.phone_number,
      maid.email,
      maid.address,
      (maid.skills || []).join(" "),
      (maid.preferred_work_type || []).join(" "),
    ]
      .join(" ")
      .toLowerCase();

    return searchableContent.includes(searchLower);
  });
  // ...existing code...

  // --- ลบ filteredMaids ออก ---
  // const filteredMaids = maids.filter(...);

  return (
    <div className={styles.container}>
      {/* --- JSX ที่แก้ไขแล้วสำหรับ Popup --- */}
      {message && (
        <div className={styles.popupOverlay}>
          <div
            className={`${styles.popup} ${
              messageType === "success"
                ? styles.popupSuccess
                : styles.popupError
            }`}
            style={{
              flexDirection: "column",
              alignItems: "center",
              gap: "1rem",
              padding: "1.25rem",
            }}
          >
            <div style={{ display: "flex", alignItems: "center", gap: "1rem" }}>
              <span className={styles.popupIcon}>
                {messageType === "success" ? "✅" : "❌"}
              </span>
              <span className={styles.popupMessage}>{message}</span>
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
      <h3 className={styles.title}>ຈັດການຂໍ້ມູນແມ່ບ້ານ</h3>
      <div className={styles.searchBox}>
        <input
          type="text"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          placeholder="ຄົ້ນຫາແມ່ບ້ານ"
          className={styles.searchInput}
        />
      </div>
      {message && (
        <div
          className={`${
            messageType === "success"
              ? "bg-green-100 border-green-400 text-green-700"
              : "bg-red-100 border-red-400 text-red-700"
          } px-4 py-3 rounded relative mb-4`}
          role="alert"
        >
          <span className="block sm:inline">{message}</span>
        </div>
      )}
      <h3 className={styles.tableHeader}>ລາຍການແມ່ບ້ານທັ້ງໝົດ</h3>
      <div className={styles.tableContainer}>
        <table className={styles.maidTable}>
          <thead>
            <tr>
              <th>ชื่อ</th>
              <th>เบอร์โทร</th>
              <th>อีเมล</th>
              <th>อายุ</th>
              <th>เพศ</th>
              <th>ทักษะ</th>
              <th>วันที่ว่าง</th>
              <th>ประเภทงาน</th>
              <th>เงินเดือน</th>
              <th>เวลาทำงาน</th>
              <th>ตำแหน่ง</th>
              <th>สถานะ</th>
            </tr>
          </thead>
          <tbody>
            {maids.length === 0 ? (
              <tr>
                <td
                  colSpan={12}
                  style={{ textAlign: "center", padding: "1rem" }}
                >
                  ยังไม่มีข้อมูลแม่บ้าน
                </td>
              </tr>
            ) : (
              maids.map((maid) => (
                <tr
                  key={maid.maid_id}
                  // ในหน้าตาราง MaidManage
                  onClick={() => router.push(`/admin/maids/${maid.maid_id}`)}
                >
                  <td>
                    <a
                      href="#"
                      onClick={(e) => {
                        e.preventDefault();
                        router.push(`/admin/maids/${maid.maid_id}`);
                      }}
                      className={styles.maidNameLink}
                    >
                      {maid.full_name}
                    </a>
                  </td>
                  <td>{maid.phone_number}</td>
                  <td>{maid.email || "-"}</td>
                  <td>{maid.age || "-"}</td>
                  <td>{maid.gender || "-"}</td>
                  <td>{(maid.skills || []).join(", ")}</td>
                  <td>{(maid.available_days || []).join(", ")}</td>
                  <td>{(maid.preferred_work_type || []).join(", ")}</td>
                  <td>{maid.expected_salary?.toLocaleString() || "-"}</td>
                  <td>
                    {maid.available_time?.start && maid.available_time?.end
                      ? `${maid.available_time.start} - ${maid.available_time.end}`
                      : "-"}
                  </td>
                  <td>
                    {maid.location?.lat && maid.location?.lng
                      ? `${maid.location.lat}, ${maid.location.lng}`
                      : "-"}
                  </td>
                  <td>
                    <span>{maid.status}</span>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
        {/* Pagination */}
        <div
          style={{
            display: "flex",
            justifyContent: "center",
            marginTop: "1rem",
            gap: "0.5rem",
          }}
        >
          <button
            onClick={() => {
              if (currentPage > 1) fetchMaids(currentPage - 1, search);
            }}
            disabled={currentPage === 1}
          >
            ก่อนหน้า
          </button>
          <span style={{ alignSelf: "center" }}>
            หน้า {currentPage} / {totalPages}
          </span>
          <button
            onClick={() => {
              if (currentPage < totalPages) fetchMaids(currentPage + 1, search);
            }}
            disabled={currentPage === totalPages}
          >
            ถัดไป
          </button>
        </div>
      </div>

      <form onSubmit={handleSubmit} className={styles.form}>
        <h4
          className={styles.title}
          style={{
            fontSize: "1.5rem",
            marginBottom: "1rem",
            gridColumn: "1 / -1",
          }}
        >
          เพิ่มแม่บ้านใหม่
        </h4>
        <input
          name="full_name"
          value={form.full_name}
          onChange={handleChange}
          placeholder="* ชื่อแม่บ้าน"
          required
          className={styles.formInput}
        />
        <input
          name="phone_number"
          value={form.phone_number}
          onChange={handleChange}
          placeholder="* เบอร์โทร"
          required
          className={styles.formInput}
        />
        <input
          name="email"
          value={form.email}
          onChange={handleChange}
          placeholder="อีเมล"
          className={styles.formInput}
        />
        <input
          name="address"
          value={form.address}
          onChange={handleChange}
          placeholder="ที่อยู่"
          className={styles.formInput}
        />
        <input
          name="age"
          type="number"
          value={form.age}
          onChange={handleChange}
          placeholder="อายุ"
          className={styles.formInput}
        />
        <select
          name="gender"
          value={form.gender}
          onChange={handleChange}
          className={styles.formSelect}
        >
          <option value="หญิง">หญิง</option>
          <option value="ชาย">ชาย</option>
          <option value="อื่นๆ">อื่นๆ</option>
        </select>
        <input
          name="skills"
          value={form.skills}
          onChange={handleChange}
          placeholder="ทักษะ (คั่นด้วย ,)"
          className={styles.formInput}
        />
        <input
          name="available_days"
          value={form.available_days}
          onChange={handleChange}
          placeholder="วันที่ว่าง (คั่นด้วย ,)"
          className={styles.formInput}
        />
        <input
          name="preferred_work_type"
          value={form.preferred_work_type}
          onChange={handleChange}
          placeholder="ประเภทงานที่ถนัด"
          className={styles.formInput}
        />
        <input
          name="expected_salary"
          type="number"
          value={form.expected_salary}
          onChange={handleChange}
          placeholder="เงินเดือนที่ต้องการ"
          className={styles.formInput}
        />
        <input
          name="lat"
          type="number"
          step="any"
          value={form.lat}
          onChange={handleChange}
          placeholder="ละติจูด (lat)"
          className={styles.formInput}
        />
        <input
          name="lng"
          type="number"
          step="any"
          value={form.lng}
          onChange={handleChange}
          placeholder="ลองจิจูด (lng)"
          className={styles.formInput}
        />
        <input
          name="start_time"
          type="time"
          value={form.start_time}
          onChange={handleChange}
          className={styles.formInput}
        />
        <input
          name="end_time"
          type="time"
          value={form.end_time}
          onChange={handleChange}
          className={styles.formInput}
        />
        <button type="submit" className={styles.submitButton}>
          เพิ่มแม่บ้าน
        </button>
      </form>

      {/* Table */}
    </div>
  );
}
