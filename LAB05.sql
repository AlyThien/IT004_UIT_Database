set dateformat dmy;

----Phan I: Quản lý bán hàng
select * from KHACHHANG;
select * from HOADON;
select * from NHANVIEN;

--11. Ngày mua hàng (NGHD) của một khách hàng thành viên sẽ lớn hơn hoặc bằng ngày khách hàng đó đăng ký thành viên (NGDK).
create trigger trg_AfterUpdate_KH
on HOADON
after insert, update
as
begin
	declare @MAKH char(4);
	select @MAKH = MAKH from inserted;
	if exists (select * from inserted join KHACHHANG kh on @MAKH = kh.MAKH
				where NGHD < NGDK)
		begin
		raiserror ('Ngay mua hang cua khach hang thanh vien khong the nho hon ngay khach hang do dang ky thanh vien', 16, 1);
		rollback transaction;
		end
end;

--Kiểm tra:
insert into HOADON values (1024, '20/7/2006', 'KH01', 'NV01', 100000);

--12. Ngày bán hàng (NGHD) của một nhân viên phải lớn hơn hoặc bằng ngày nhân viên đó vào làm.
create trigger trg_checknghd_hdnv
on HOADON
after insert, update
as
begin
	declare @MANV char(4);
	select @MANV = MANV from inserted;
	if exists (select * from inserted join NHANVIEN nv on @MANV = nv.MANV
				where NGHD < NGVL)
		begin
		raiserror ('Ngay ban hang cua mot nhan vien khong the nho hon ngay nhan vien do vao lam', 16, 2);
		rollback transaction;
		end
end;

--Kiểm tra:
insert into HOADON values (1025, '9/5/2006', 'KH03', 'NV04', 100000);

----Phần I: Quản lý giáo vụ
select * from LOP;
select * from HOCVIEN;
select * from KHOA;
select * from GIAOVIEN;
select * from GIANGDAY;
select * from KETQUATHI;
select * from DIEUKIEN;

--9. Lớp trưởng của một lớp phải là học viên của lớp đó.
create trigger trg_check_trglop
on LOP
after insert, update
as
begin
	declare @TRGLOP char(5);
	select @TRGLOP = TRGLOP from inserted;
	if exists (select * from inserted t1 join HOCVIEN hv on @TRGLOP = hv.MAHV
				where t1.MALOP != hv.MALOP)
		begin
		raiserror ('Hoc vien khong thuoc lop nay, khong the thanh lop truong', 16, 3);
		rollback transaction;
		end
end;

create trigger trg_del_HOCVIEN
on HOCVIEN
after delete
as 
begin
	if exists (select * from inserted t join LOP l on t.MAHV = l.TRGLOP
				where t.MALOP = l.MALOP)
		begin
		raiserror ('Hoc vien hien tai dang la lop truong', 16, 4);
		rollback transaction;
		end
end;

--Kiểm tra:
update LOP
set TRGLOP = 'K1205'
where MALOP = 'K11';

--10. Trưởng khoa phải là giáo viên thuộc khoa và có học vị “TS” hoặc “PTS”.
create trigger trg_check_trgkhoa
on KHOA
after update, insert
as
begin
	declare @trgkhoa char(4);
	select @trgkhoa = TRGKHOA from inserted;
	if exists (select * from inserted t join GIAOVIEN gv on @trgkhoa = gv.MAGV
				where gv.MAKHOA != t.MAKHOA and (gv.HOCVI != 'TS' or gv.HOCVI != 'PTS'))
		begin
		raiserror ('Truong khoa duoc them/cap nhat khong phai la giao vien thuoc khoa do va co hoc vi khong phai la "TS" hoac "PTS"', 16, 5);
		rollback transaction;
		end
end

--Kiem tra:
update KHOA
set TRGKHOA = 'GV02'
where MAKHOA = 'CNPM';

--15. Học viên chỉ được thi một môn học nào đó khi lớp của học viên đã học xong môn học này.
create trigger trg_checkthi_lop
on KETQUATHI
after update, insert
as
begin
	declare @mahv char(5);
	select @mahv = MAHV from inserted;
	if exists (select * from inserted t join HOCVIEN hv on @mahv = hv.MAHV
										join GIANGDAY gd on hv.MALOP = gd.MALOP
				where NGTHI < DENNGAY)
		begin
		raiserror ('Hoc vien trong lop nay chua hoc xong mon hoc nay nen khong the thi', 16, 6);
		rollback transaction;
		end
end

--Kiem tra:
insert into KETQUATHI values ('K1102', 'DHMT', 1, 19/3/2007, 5, 'Dat');

--16. Mỗi học kỳ của một năm học, một lớp chỉ được học tối đa 3 môn.
create trigger trg_checksomon_giangday
on GIANGDAY
after update, insert
as
begin
	if exists (select MALOP, HOCKY, NAM, count(MAMH) 'So mon' from inserted
				group by HOCKY, MALOP, NAM
				having count(MAMH) <= 3)
	begin
	raiserror ('Trong hoc ki cua nam hoc nay, mot lop chi duoc hoc toi da 3 mon', 16, 7);
	rollback transaction;
	end
end

--Kiem tra:
insert into GIANGDAY values ('K11', 'ABC', 'GV01', 1, 2006, 1/1/2006, 10/1/2006);
insert into GIANGDAY values ('K11', 'HIJ', 'GV01', 1, 2006, 1/1/2006, 10/1/2006);

--17. Sỉ số của một lớp bằng với số lượng học viên thuộc lớp đó.
create trigger trg_checksiso_lop
on LOP
after update, insert
as 
begin
	if exists (select count(MAHV) from HOCVIEN hv join inserted t on hv.MALOP = t.MALOP
				group by hv.MALOP
				having count(hv.MAHV) not in (select SISO from LOP))		
		begin
		raiserror ('Si so cua lop khong bang voi so luong hoc vien thuoc lop do', 16, 8);
		rollback transaction;
		end
end

--Kiem tra:
update LOP
set SISO = 13
where MALOP = 'K11'

--18. Trong quan hệ DIEUKIEN giá trị của thuộc tính MAMH và MAMH_TRUOC trong cùng một bộ không được giống nhau (“A”,”A”) và cũng không tồn tại hai bộ (“A”,”B”) và (“B”,”A”).
create trigger trg_check_dieukien
on DIEUKIEN
after update, insert
as
begin
	if exists (select * from inserted t join DIEUKIEN dk on t.MAMH = dk.MAMH
				where t.MAMH = t.MAMH_TRUOC or (dk.MAMH = t.MAMH_TRUOC and t.MAMH = dk.MAMH_TRUOC))
		begin
		raiserror ('Gia tri thuoc tinh MAMH va MAMH_TRUOC giong nhau hoac cung ton tai 2 bo trai nguoc nhau', 16, 9);
		rollback transaction;
		end
end

--Kiem tra:
insert into DIEUKIEN values ('CTDLGT', 'CTDLGT');

--19. Các giáo viên có cùng học vị, học hàm, hệ số lương thì mức lương bằng nhau.
create trigger trg_checkhesolg_giaovien
on GIAOVIEN
after update, insert
as
begin
	declare @mucluong money;
	select @mucluong = MUCLUONG from inserted;
	if exists (select HOCHAM, HOCVI, HESO from GIAOVIEN
				where @mucluong != MUCLUONG
				group by HOCHAM, HOCVI, HESO)
		begin
		raiserror ('Giao vien duoc cap nhat/them vao co muc luong khac so voi cac giao vien co cung hoc vi, hoc ham, he so luong', 16, 10)
		rollback transaction;
		end
end

--Kiem tra:
insert into GIAOVIEN values ('GV19', 'Nguyen Van D', 'TS', 'PGS', 'Nam', 20/09/1993, 29/11/2004, 4.50, 10000000, 'KHMT');

--20. Học viên chỉ được thi lại (lần thi >1) khi điểm của lần thi trước đó dưới 5.
create trigger trg_checkthilai_ketquathi
on KETQUATHI
after update, insert
as 
begin
	if exists (select * from inserted t join KETQUATHI kqt on t.MAHV = kqt.MAHV and t.MAMH = kqt.MAMH and t.LANTHI = kqt.LANTHI
				where kqt.DIEM >= 5)
		begin 
		raiserror ('Hoc vien chi duoc thi lai khi diem cua lan thi truoc do duoi 5', 16, 11)
		rollback transaction;
		end
end


--Kiem tra:
insert into KETQUATHI values ('K1101', 'CSDL', 2, 09/10/2006, 5, 'Dat');

--21. Ngày thi của lần thi sau phải lớn hơn ngày thi của lần thi trước (cùng học viên, cùng môn học).
create trigger TRG_INS_KQT_NT 
on KETQUATHI
for insert
as
begin
	declare @MaHV CHAR(5), @MaMH CHAR(10), @NgayThiTruoc SMALLDATETIME, @NgayThiSau SMALLDATETIME
	select @MaHV = MAHV, @MaMH = MAMH from INSERTED

	select @NgayThiTruoc = NGTHI
	from KETQUATHI KQT1
	where MAMH IN (select MAMH
					from KETQUATHI KQT2
					where KQT1.MAHV = KQT2.MAHV
						AND KQT1.LANTHI = 1
						AND KQT1.MAMH = KQT2.MAMH)

	select @NgayThiSau = NGTHI
	from KETQUATHI KQT1
	where MAMH IN (select MAMH
					from KETQUATHI KQT2
					where KQT1.MAHV = KQT2.MAHV
						AND KQT1.LANTHI <> 1
						AND KQT1.MAMH = KQT2.MAMH)

	if(@NgayThiSau < @NgayThiTruoc)
	begin
		raiserror('LOI: NGAY THI SAU KHONG HOP LE', 16, 12);
		rollback transaction;
	end
end

--22. Học viên chỉ được thi những môn mà lớp của học viên đó đã học xong.
--Tương tự câu 15 phía trên
create trigger trg_checkthi_lop
on KETQUATHI
after update, insert
as
begin
	declare @mahv char(5);
	select @mahv = MAHV from inserted;
	if exists (select * from inserted t join HOCVIEN hv on @mahv = hv.MAHV
										join GIANGDAY gd on hv.MALOP = gd.MALOP
				where NGTHI < DENNGAY)
		begin
		raiserror ('Hoc vien trong lop nay chua hoc xong mon hoc nay nen khong the thi', 16, 6);
		rollback transaction;
		end
end

--Kiem tra:
insert into KETQUATHI values ('K1102', 'DHMT', 1, 19/3/2007, 5, 'Dat');

--23. Khi phân công giảng dạy một môn học, phải xét đến thứ tự trước sau giữa các môn học (sau khi học xong những môn học phải học trước mới được học những môn liền sau).
--24. Giáo viên chỉ được phân công dạy những môn thuộc khoa giáo viên đó phụ trách.
create trigger trg_checkkhoa_giangday
on GIANGDAY
for insert, update
as
begin
	if exists (select * from inserted t join GIAOVIEN gv on t.MAGV = gv.MAGV
										join MONHOC mh on t.MAMH = mh.MAMH
				where gv.MAKHOA <> mh.MAKHOA)
		begin 
		raiserror ('Giao vien chi duoc phan cong day nhung mon thuoc khoa giao vien do phu trach', 16, 13);
		rollback transaction;
		end
end