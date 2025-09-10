--Phần I: Ngôn ngữ định nghĩa dữ liệu
--1. Tạo quan hệ và khai báo tất cả các ràng buộc khóa chính, khóa ngoại. Thêm vào 3 thuộc tính GHICHU, DIEMTB, XEPLOAI cho quan hệ HOCVIEN.
alter table HOCVIEN add GHICHU varchar(100);
alter table HOCVIEN add DIEMTB numberic(4,2 );
alter table HOCVIEN add XEPLOAI varchar(10);

select * from HOCVIEN;
select * from KETQUATHI;
select * from GIANGDAY;
select * from LOP;
select * from GIAOVIEN;
select * from MONHOC;
select * from DIEUKIEN;
select * from KHOA;

--3. Thuộc tính GIOITINH chỉ có giá trị là “Nam” hoặc “Nu”.
alter table HOCVIEN add check (GIOITINH = 'Nam' or GIOITINH = 'Nu'); 
alter table GIAOVIEN add check (GIOITINH in ('Nam', 'Nu'));

--4. Điểm số của một lần thi có giá trị từ 0 đến 10 và cần lưu đến 2 số lẽ (VD: 6.22).
alter table KETQUATHI add constraint CHK_DIEM check (DIEM between 0 and 10 and right(cast(DIEM as varchar), 3) like '.__');

--5. Kết quả thi là “Dat” nếu điểm từ 5 đến 10 và “Khong dat” nếu điểm nhỏ hơn 5.
alter table KETQUATHI add check
(
	(KQUA = 'Dat' and DIEM between 5 and 10)
	or (KQUA = 'Khong dat' and DIEM < 5)
);

--6. Học viên thi một môn tối đa 3 lần.
alter table KETQUATHI add check (LANTHI <= 3);

--7. Học kỳ chỉ có giá trị từ 1 đến 3.
alter table GIANGDAY add check (HOCKY in (1, 2, 3));

--8. Học vị của giáo viên chỉ có thể là “CN”, “KS”, “Ths”, ”TS”, ”PTS”.
alter table GIAOVIEN add check (HOCVI in ('CN', 'KS', 'Ths', 'TS', 'PTS'));

--11. Học viên ít nhất là 18 tuổi.
alter table HOCVIEN add check (year(getdate()) - year(NGSINH) >= 18);

--12. Giảng dạy một môn học ngày bắt đầu (TUNGAY) phải nhỏ hơn ngày kết thúc (DENNGAY).
alter table GIANGDAY add check (TUNGAY < DENNGAY);

--13. Giáo viên khi vào làm ít nhất là 22 tuổi.
alter table GiAOVIEN add check (year(getdate()) - year(NGSINH) >= 22);

alter table GIAOVIEN add check ((NGVL - NGSINH) >= 22);

--14. Tất cả các môn học đều có số tín chỉ lý thuyết và tín chỉ thực hành chênh lệch nhau không quá 3.
alter table MONHOC add check (abs (TCLT - TCTH) <= 3);

--Phần II: Ngôn ngữ thao tác dữ liệu
--1. Tăng hệ số lương thêm 0.2 cho những giáo viên là trưởng khoa.
update GIAOVIEN
set HESO = 0.2 + HESO
where MAGV in (select TRGKHOA from KHOA);

--2. Cập nhật giá trị điểm trung bình tất cả các môn học (DIEMTB) của mỗi học viên 
--(tất cả các môn học đều có hệ số 1 và nếu học viên thi một môn nhiều lần, chỉ lấy điểm của lần thi sau cùng).
update HOCVIEN
set DIEMTB = (select AVG(DIEM)
				from KETQUATHI KQT
				where KQT.MAHV = HOCVIEN.MAHV and
						LANTHI = (select MAX(LANTHI)
									from KETQUATHI KQ2
									where KQ2.MAHV = KQT.MAHV and KQ2.MAMH = KQT.MAMH));

--3. Cập nhật giá trị cho cột GHICHU là “Cam thi” đối với trường hợp: học viên có một môn bất kỳ thi lần thứ 3 dưới 5 điểm.
update HOCVIEN
set GHICHU = 'Cam thi'
where MAHV in (select MAHV
				from KETQUATHI
				where (LANTHI = 3) and (DIEM < 5));

--4. Cập nhật giá trị cho cột XEPLOAI trong quan hệ HOCVIEN như sau:
--o Nếu DIEMTB  9 thì XEPLOAI =”XS”
--o Nếu 8  DIEMTB < 9 thì XEPLOAI = “G”
--o Nếu 6.5  DIEMTB < 8 thì XEPLOAI = “K”
--o Nếu 5  DIEMTB < 6.5 thì XEPLOAI = “TB”
--o Nếu DIEMTB < 5 thì XEPLOAI = ”Y”
update HOCVIEN
set XEPLOAI =
(
	case
		when DIEMTB >= 9 then 'XS'
		when DIEMTB >=8 and DIEMTB < 9 then 'G'
		when DIEMTB >=6.5 and DIEMTB < 8 then 'K'
		when DIEMTB >= 5 and DIEMTB < 6.5 then 'TB'
		when DIEMTB < 5 then 'Y'
);

--Phần III: Ngôn ngữ truy vấn dữ liệu
--1. In ra danh sách (mã học viên, họ tên, ngày sinh, mã lớp) lớp trưởng của các lớp.
select MAHV, (HO + TEN) HOTEN, NGSINH, HV.MALOP
from HOCVIEN HV join LOP LP on HV.MAHV = LP.TRGLOP;

--2. In ra bảng điểm khi thi (mã học viên, họ tên , lần thi, điểm số) môn CTRR của lớp “K12”, sắp xếp theo tên, họ học viên.
select KQT.MAHV, (HO + TEN) HOTEN, LANTHI, DIEM
from HOCVIEN HV join KETQUATHI KQT on HV.MAHV = KQT.MAHV
where MAMH = 'CTRR' and MALOP = 'K12'
order by HOTEN;

--3. In ra danh sách những học viên (mã học viên, họ tên) và những môn học mà học viên đó thi lần thứ nhất đã đạt.
select KQT.MAHV, (HO + TEN) HOTEN, MAMH
from HOCVIEN HV join KETQUATHI KQT on HV.MAHV = KQT.MAHV
where KQT.LANTHI = 1 and KQUA = 'Dat';

--4. In ra danh sách học viên (mã học viên, họ tên) của lớp “K11” thi môn CTRR không đạt (ở lần thi 1).
select KQT.MAHV, (HO + TEN) HOTEN
from HOCVIEN HV join KETQUATHI KQT on HV.MAHV = KQT.MAHV
where LANTHI = 1 and MAMH = 'CTRR' and HV.MALOP = 'K11' and KQUA = 'Khong dat';

--5. * Danh sách học viên (mã học viên, họ tên) của lớp “K” thi môn CTRR không đạt (ở tất cả các lần thi).
select distinct KQT.MAHV, (HO + TEN) HOTEN
from HOCVIEN HV join KETQUATHI KQT on HV.MAHV = kqt.MAHV
where MAMH = 'CTRR' and MALOP like 'K%'
					and not exists (select *
									from KETQUATHI KQT1
									where MAMH = 'CTRR' and KQUA = 'Dat'
										and KQT1.MAHV = HV.MAHV);

--6. Tìm tên những môn học mà giáo viên có tên “Tran Tam Thanh” dạy trong học kỳ 1 năm 2006.
select distinct gd.MAMH, mh.TENMH
from GIANGDAY gd join GIAOVIEN gv on gd.MAGV = gv.MAGV
				join MONHOC mh on gd.MAMH = mh.MAMH
where (gv.HOTEN = 'Tran Tam Thanh') and gd.HOCKY = 1 and gd.NAM = 2006;

--7. Tìm những môn học (mã môn học, tên môn học) mà giáo viên chủ nhiệm lớp “K11” dạy trong học kỳ 1 năm 2006.
select distinct gd.MAMH, TENMH
from GIANGDAY gd join MONHOC mh on gd.MAMH = mh.MAMH
				join LOP l on gd.MAGV = l.MAGVCN
where l.MALOP = 'K11' and gd.HOCKY = 1 and gd.NAM = 2006;

--8. Tìm họ tên lớp trưởng của các lớp mà giáo viên có tên “Nguyen To Lan” dạy môn “Co So Du Lieu”.
select TRGLOP, (HO + TEN) HOTEN
from GIANGDAY gd join GIAOVIEN gv on gd.MAGV = gv.MAGV
				join LOP l on l.MALOP = gd.MALOP
				join HOCVIEN hv on hv.MAHV = l.TRGLOP
				join MONHOC mh on mh.MAMH = gd.MAMH
where gv.HOTEN = 'Nguyen To Lan' and mh.TENMH = 'Co So Du Lieu';
				
--9. In ra danh sách những môn học (mã môn học, tên môn học) phải học liền trước môn “Co So Du Lieu”.
select dk.MAMH_TRUOC, TENMH
from DIEUKIEN dk join MONHOC mh on dk.MAMH_TRUOC = mh.MAMH
where dk.MAMH in (select MAMH
					from MONHOC
					where TENMH = 'Co So Du Lieu');

--10. Môn “Cau Truc Roi Rac” là môn bắt buộc phải học liền trước những môn học (mã môn học, tên môn học) nào.
select dk.MAMH, TENMH
from DIEUKIEN dk join MONHOC mh on dk.MAMH = mh.MAMH
where MAMH_TRUOC in (select MAMH
					from MONHOC
					where TENMH = 'Cau Truc Roi Rac');

--11. Tìm họ tên giáo viên dạy môn CTRR cho cả hai lớp “K11” và “K12” trong cùng học kỳ 1 năm 2006.
select distinct HOTEN
from GIAOVIEN gv join GIANGDAY gd on gv.MAGV = gd.MAGV
where gd.MAMH = 'CTRR' and gd.MALOP in ('K11', 'K12') and gd.HOCKY = 1 and gd.NAM = 2006;

--12. Tìm những học viên (mã học viên, họ tên) thi không đạt môn CSDL ở lần thi thứ 1 nhưng chưa thi lại môn này.
select hv.MAHV, (HO + TEN) HOTEN
from HOCVIEN hv join KETQUATHI kqt on hv.MAHV = kqt.MAHV
where hv.MAHV in (select MAHV
				from KETQUATHI
				where MAMH = 'CSDL'and KQUA = 'Khong Dat'
				except 
				select distinct MAHV
				from KETQUATHI
				where MAMH = 'CSDL' and LANTHI > 1);

--13. Tìm giáo viên (mã giáo viên, họ tên) không được phân công giảng dạy bất kỳ môn học nào.
select MAGV, HOTEN 
from GIAOVIEN 
except 
select MAGV, HOTEN
from GIAOVIEN
where MAGV in (select distinct MAGV
				from GIANGDAY);

--14. Tìm giáo viên (mã giáo viên, họ tên) không được phân công giảng dạy bất kỳ môn học nào thuộc khoa giáo viên đó phụ trách.
select MAGV, HOTEN
from GIAOVIEN
where MAKHOA not in (select distinct MAKHOA
					from MONHOC
					where MONHOC.MAMH in (select distinct MAMH
											from GIANGDAY));

--15. Tìm họ tên các học viên thuộc lớp “K11” thi một môn bất kỳ quá 3 lần vẫn “Khong dat” hoặc thi lần thứ 2 môn CTRR được 5 điểm.
select hv.MAHV, (HO + TEN) HOTEN
from HOCVIEN hv 
where MALOP = 'K11' and MAHV in (select MAHV
								from KETQUATHI
								where (LANTHI = 3 and KQUA = 'Khong Dat') or (LANTHI = 2 and MAMH = 'CTRR' and DIEM = 5));

--16. Tìm họ tên giáo viên dạy môn CTRR cho ít nhất hai lớp trong cùng một học kỳ của một năm học.
select HOTEN
from GIAOVIEN
where MAGV in (select MAGV
				from GIANGDAY t1
				where MAMH = 'CTRR' and MAGV in (select MAGV
													from GIANGDAY t2
													where MAMH = 'CTRR' and t1.HOCKY = t2.HOCKY and t1.NAM = t2.NAM));

--17. Danh sách học viên và điểm thi môn CSDL (chỉ lấy điểm của lần thi sau cùng).
select hv.MAHV, (HO + TEN) HOTEN, DIEM
from KETQUATHI kqt left join HOCVIEN hv on hv.MAHV = kqt.MAHV
where MAMH = 'CSDL' and LANTHI in (select top 1 LANTHI
									from KETQUATHI t2
									where t2.MAMH = kqt.MAMH and t2.MAHV = kqt.MAHV
									order by LANTHI desc);

--18. Danh sách học viên và điểm thi môn “Co So Du Lieu” (chỉ lấy điểm cao nhất của các lần thi).
select hv.MAHV, (HO +TEN) HOTEN, DIEM
from KETQUATHI kqt left join HOCVIEN hv on hv.MAHV = kqt.MAHV
where MAMH = 'CSDL' and DIEM = (select max(DIEM)
								from KETQUATHI t2
								where t2.MAMH = kqt.MAMH and t2.MAHV = kqt.MAHV
								group by t2.MAMH, t2.MAHV);

--19. Khoa nào (mã khoa, tên khoa) được thành lập sớm nhất.
select top 1 with ties MAKHOA, TENKHOA
from KHOA
order by NGTLAP asc;

--20. Có bao nhiêu giáo viên có học hàm là “GS” hoặc “PGS”.
select count(MAGV) 'Tong so giao vien voi hoc ham la GS hoac PGS'
from GIAOVIEN
where HOCHAM = 'GS' or HOCHAM = 'PGS';

--21. Thống kê có bao nhiêu giáo viên có học vị là “CN”, “KS”, “Ths”, “TS”, “PTS” trong mỗi khoa.
select count(MAGV) 'Tong so giao vien', MAKHOA
from GIAOVIEN
where HOCVI = 'CN' or HOCVI = 'KS' or hocvi = 'Ths' or HOCVI = 'TS' or HOCVI = 'PTS'
group by MAKHOA;

--22. Mỗi môn học thống kê số lượng học viên theo kết quả (đạt và không đạt).
(select MAMH, count(MAHV) 'Tong so hoc vien dat va khong dat'
from KETQUATHI
where KQUA = 'Dat'
group by MAMH)
union
(select MAMH, count(MAHV) 
from KETQUATHI
where KQUA = 'Khong Dat'
group by MAMH)

--23. Tìm giáo viên (mã giáo viên, họ tên) là giáo viên chủ nhiệm của một lớp, đồng thời dạy cho lớp đó ít nhất một môn học.
select MAGV, HOTEN
from GIAOVIEN
where MAGV in (select MAGVCN
				from LOP
				where MALOP in (select MALOP
								from GIANGDAY));

--24. Tìm họ tên lớp trưởng của lớp có sỉ số cao nhất.
select MAHV, (HO + TEN) HOTEN
from HOCVIEN
where MAHV in (select TRGLOP
				from LOP
				where SISO in (select max(SISO)
								from LOP));