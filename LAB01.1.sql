create database QuanLyKhachHang;

use QuanLyKhachHang;

create table SACH
(
	MaSach char(5) primary key NOT NULL,
	TenSach nvarchar(20),
	TheLoai nvarchar(20),
	NXB nvarchar(20)
);

create table KHACHHANG
(
	MaKH char(5) primary key NOT NULL,
	HoTen nvarchar(25),
	NgaySinh smalldatetime,
	DiaChi nvarchar(50),
	SDT varchar(15),
	NgDK smalldatetime
);

create table CHITET_PHIEUMUA
(
	MaSach char(5),
	MaPM char(5),
	CONSTRAINT ct_pm primary key (MaSach, MaPM)
);

create table PHIEUMUA
(
	MaPM char(5),
	MaKH char(5),
	NgMUA smalldatetime,
	SoSachMua int
);

