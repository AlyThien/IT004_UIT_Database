set dateformat dmy
select * from SANPHAM;
select * from HOADON;
select * from KHACHHANG;
select * from NHANVIEN;
select * from CTHD;

--III. Ngôn ngữ truy vấn dữ liệu:
--1. In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quoc” sảnn xuất.
select MASP, TENSP
from SANPHAM
where NUOCSX = 'Trung Quoc';

--2. In ra danh sách các sản phẩm (MASP, TENSP) có đơn vị tính là “cay”, ”quyen”.
select MASP, TENSP
from SANPHAM
where DVT = 'cay' OR DVT = 'quyen';

--3. In ra danh sách các sản phẩm (MASP,TENSP) có mã sản phẩm bắt đầu là “B” và kết 
--thúc là “01”.
select MASP, TENSP
from SANPHAM
where MASP like 'B%01';

--4. In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quốc” sản xuất có giá từ 30.000 
--đến 40.000.
select MASP, TENSP
from SANPHAM
where NUOCSX = 'Trung Quoc' AND GIA between 30000 and 40000;

--5. In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quoc” hoặc “Thai Lan” sản 
--xuất có giá từ 30.000 đến 40.000.
select MASP, TENSP
from SANPHAM
where (NUOCSX = 'Trung Quoc' or NUOCSX = 'Thai Lan') and GIA between 30000 and 40000;

--6. In ra các số hóa đơn, trị giá hóa đơn bán ra trong ngày 1/1/2007 và ngày 2/1/2007.
select SOHD, TRIGIA
from HOADON
where NGHD = '1/1/2007' or NGHD = '2/1/2007';

--7. In ra các số hóa đơn, trị giá hóa đơn trong tháng 1/2007, sắp xếp theo ngày (tăng dần) và 
--trị giá của hóa đơn (giảm dần).
select SOHD, TRIGIA
from HOADON
where (MONTH(NGHD) = 1 and YEAR(NGHD) = 2007)
order by NGHD ASC, TRIGIA DESC;

--8. In ra danh sách các khách hàng (MAKH, HOTEN) đã mua hàng trong ngày 1/1/2007.
select kh.MAKH, HOTEN
from KHACHHANG kh inner join HOADON hd on kh.MAKH = hd.MAKH
where NGHD = '1/1/2007';

--9. In ra số hóa đơn, trị giá các hóa đơn do nhân viên có tên “Nguyen Van B” lập trong ngày 
--28/10/2006.
select SOHD, TRIGIA
from HOADON hd inner join NHANVIEN nv on hd.MANV = nv.MANV
where nv.HOTEN = 'Nguyen Van B' and NGHD = '28/10/2006';

--10. In ra danh sách các sản phẩm (MASP,TENSP) được khách hàng có tên “Nguyen Van A” 
--mua trong tháng 10/2006.
--Cach 1:
select sp.MASP, sp.TENSP
from SANPHAM sp, CTHD ct, HOADON hd, KHACHHANG kh
where (hd.SOHD = ct.SOHD and ct.MASP = sp.MASP and hd.MAKH = kh.MAKH) and kh.HOTEN = 'Nguyen Van A' and (YEAR(hd.NGHD) = 2006 and MONTH(hd.NGHD) = 10);
--Cach 2:
select sp.MASP, sp.TENSP
from SANPHAM sp join CTHD ct on sp.MASP = ct.MASP
				join HOADON hd on hd.SOHD = ct.SOHD
				join KHACHHANG kh on kh.MAKH = hd.MAKH
where kh.HOTEN = 'Nguyen Van A' and (YEAR(hd.NGHD) = 2006 and MONTH(hd.NGHD) = 10);

--11. Tìm các số hóa đơn đã mua sản phẩm có mã số “BB01” hoặc “BB02”.
(select SOHD
from CTHD
where MASP = 'BB01')
UNION
(select SOHD
from CTHD
where MASP = 'BB02');

--12. Tìm các số hóa đơn đã mua sản phẩm có mã số “BB01” hoặc “BB02”, mỗi sản phẩm 
--mua với số lượng từ 10 đến 20.
(select SOHD
from CTHD
where MASP = 'BB01' and SL between 10 and 20)
UNION
(select SOHD
from CTHD
where MASP = 'BB02' and SL between 10 and 20);

--13. Tìm các số hóa đơn mua cùng lúc 2 sản phẩm có mã số “BB01” và “BB02”, mỗi sản 
--phẩm mua với số lượng từ 10 đên 20.
(select SOHD
from CTHD
where MASP = 'BB01' and SL between 10 and 20)
INTERSECT
(select SOHD
from CTHD
where MASP = 'BB02' and SL between 10 and 20);

--14. In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quoc” sản xuất hoặc các sản 
--phẩm được bán ra trong ngày 1/1/2007.
(select MASP, TENSP
from SANPHAM
where NUOCSX = 'Trung Quoc')
UNION
(select sp.MASP, sp.TENSP
from SANPHAM sp inner join CTHD ct on sp.MASP = ct.MASP
					join HOADON hd on ct.SOHD = hd.SOHD
where NGHD = '1/1/2007');

--15. In ra danh sách các sản phẩm (MASP,TENSP) không bán được.
(select MASP, TENSP
from SANPHAM)
EXCEPT
(select sp.MASP, sp.TENSP
from SANPHAM sp inner join CTHD ct on sp.MASP = ct.MASP
					join HOADON hd on ct.SOHD = hd.SOHD);

--16. In ra danh sách các sản phẩm (MASP,TENSP) không bán được trong năm 2006.
(select MASP, TENSP
from SANPHAM)
EXCEPT
(select sp.MASP, sp.TENSP
from SANPHAM sp inner join CTHD ct on sp.MASP = ct.MASP
					join HOADON hd on ct.SOHD = hd.SOHD
where YEAR(hd.NGHD) = 2006);

--17. In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quoc” sản xuất không bán 
--được trong năm 2006
(select MASP, TENSP
from SANPHAM
where NUOCSX = 'Trung Quoc')
EXCEPT
(select sp.MASP, sp.TENSP
from SANPHAM sp inner join CTHD ct on sp.MASP = ct.MASP
					join HOADON hd on ct.SOHD = hd.SOHD
where YEAR(hd.NGHD) = 2006);
