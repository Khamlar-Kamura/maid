"use client";
import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import MaidManage from "../components/MaidManage";
import UserManage from "../components/UserManage";
import PaymentReport from "../components/PaymentReport";
import BookingReport from "../components/BookingReport";

export default function Dashboard() {
  const [page, setPage] = useState(1);
  const router = useRouter();

  useEffect(() => {
    if (!localStorage.getItem("admin")) router.push("/admin/login");
  }, []);

  return (
    <div
      style={{
        width: "100%",
        maxWidth: 1400,
        margin: "0 auto",
        padding: "32px 0",
      }}
    >
      <h2 style={{ marginBottom: 24, fontWeight: 600, fontSize: 24 }}>
        Admin Dashboard
      </h2>
      <div
        style={{
          display: "flex",
          gap: 0,
          borderBottom: "2px solid #e0e0e0",
          marginBottom: 32,
          alignItems: "flex-end",
          background: "#fff",
        }}
      >
        <TabButton active={page === 1} onClick={() => setPage(1)}>
          จัดการแม่บ้าน
        </TabButton>
        <TabButton active={page === 2} onClick={() => setPage(2)}>
          จัดการผู้ใช้
        </TabButton>
        <TabButton active={page === 3} onClick={() => setPage(3)}>
          รายรับ-รายจ่าย
        </TabButton>
        <TabButton active={page === 4} onClick={() => setPage(4)}>
          ยอดจองแม่บ้าน
        </TabButton>
        <TabButton active={page === 5} onClick={() => setPage(5)}>
          อื่นๆ
        </TabButton>
      </div>
      <div>
        {page === 1 && <MaidManage />}
        {page === 2 && <UserManage />}
        {page === 3 && <PaymentReport />}
        {page === 4 && <BookingReport />}
        {page === 5 && <div>Coming soon...</div>}
      </div>
    </div>
  );
}

function TabButton({ active, onClick, children }) {
  return (
    <button
      onClick={onClick}
      style={{
        background: "none",
        border: "none",
        borderBottom: active ? "3px solid #1976d2" : "3px solid transparent",
        color: active ? "#1976d2" : "#333",
        backgroundColor: active ? "#f5faff" : "transparent",
        fontSize: 18,
        padding: "12px 28px",
        cursor: "pointer",
        outline: "none",
        transition: "border 0.2s, color 0.2s, background 0.2s",
        fontWeight: 500,
      }}
    >
      {children}
    </button>
  );
}
