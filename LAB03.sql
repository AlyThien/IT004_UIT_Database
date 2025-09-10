set dateformat dmy;
select * from HOADON;
select * from KHACHHANG;
select * from CTHD;
select * from SANPHAM;

--18. Tìm số hóa đơn đã mua tất cả các sản phẩm do Singapore sản xuất.
--CACH 1:
select HD.SOHD
from HOADON HD
where not exists (select *
					from SANPHAM SP
					where SP.NUOCSX = 'Singapore'
			and not exists (select *
							from CTHD CT
							where HD.SOHD = CT.SOHD
								and CT.MASP = SP.MASP));

--CACH 2:
select hd.SOHD
from HOADON hd join CTHD ct on hd.SOHD = ct.SOHD
				join SANPHAM sp on ct.MASP = sp.MASP
where sp.NUOCSX = 'Singapore'
group by hd.SOHD
having count (distinct ct.MASP) = (select count(MASP)
									from SANPHAM
									where NUOCSX = 'Singapore');

--19. Tìm số hóa đơn trong năm 2006 đã mua tất cả các sản phẩm do Singapore sản 
--xuất.
select HD.SOHD
from HOADON HD
where year(HD.NGHD) = 2006 and not exists (select * 
												from SANPHAM SP
												where SP.NUOCSX = 'Singapore'
								and not exists (select *
											from CTHD CT
											where HD.SOHD = CT.SOHD
											and CT.MASP = SP.MASP));

--20. Có bao nhiêu hóa đơn không phải của khách hàng đăng ký thành viên mua?
select count(SOHD) 'SoLgHoaDon'
from HOADON
where MAKH is null;

--21. Có bao nhiêu sản phẩm khác nhau được bán ra trong năm 2006.
select count(distinct MASP) 'SoSP'
from CTHD ct inner join HOADON hd on ct.SOHD = hd.SOHD
where year(hd.NGHD) = 2006;

--22. Cho biết trị giá hóa đơn cao nhất, thấp nhất là bao nhiêu ?
--CACH 1:
select max(TRIGIA) 'GiaTriMAX', min(TRIGIA) 'GiaTriMIN'
from HOADON;

--CACH 2:
(select SOHD, TRIGIA
from HOADON
where TRIGIA = (select max(TRIGIA)
				from HOADON))
union
(select SOHD, TRIGIA
from HOADON
where TRIGIA = (select min(TRIGIA)
				from HOADON));

--23. Trị giá trung bình của tất cả các hóa đơn được bán ra trong năm 2006 là bao nhiêu?
select avg(TRIGIA) 'TriGiaTB'
from HOADON
where year(NGHD) = 2006;

--24. Tính doanh thu bán hàng trong năm 2006.
select sum(TRIGIA) 'DoanhThu'
from HOADON
where year(NGHD) = 2006;

--25. Tìm số hóa đơn có trị giá cao nhất trong năm 2006.
--CACH 1:
select top 1 with ties SOHD, TRIGIA
from HOADON
where year(NGHD) = 2006
order by TRIGIA DESC;

--CACH 2:
select SOHD, TRIGIA
from HOADON
where year(NGHD) = 2006 and TRIGIA = (select max(TRIGIA)
										from HOADON
										where year(NGHD) = 2006);

--26. Tìm họ tên khách hàng đã mua hóa đơn có trị giá cao nhất trong năm 2006.
select kh.MAKH, HOTEN
from KHACHHANG kh join HOADON hd on kh.MAKH = hd.MAKH
where year(NGHD) = 2006 and TRIGIA = (select max(TRIGIA)
										from HOADON
										where year(NGHD) = 2006);

--27. In ra danh sách 3 khách hàng đầu tiên (MAKH, HOTEN) sắp xếp theo doanh số giảm 
--dần.
select distinct top 3 MAKH, HOTEN, DOANHSO
from KHACHHANG
order by DOANHSO desc;

--28. In ra danh sách các sản phẩm (MASP, TENSP) có giá bán bằng 1 trong 3 mức giá cao 
--nhất.
select MASP, TENSP
from SANPHAM
where GIA in (select distinct top 3 GIA
				from SANPHAM
				order by GIA desc);

--29. In ra danh sách các sản phẩm (MASP, TENSP) do “Thai Lan” sản xuất có giá bằng 1 
--trong 3 mức giá cao nhất (của tất cả các sản phẩm).
select MASP, TENSP
from SANPHAM
where NUOCSX = 'Thai Lan' and  GIA in (select distinct top 3 GIA
										from SANPHAM
										order by GIA desc);

--30. In ra danh sách các sản phẩm (MASP, TENSP) do “Trung Quoc” sản xuất có giá bằng 1 
--trong 3 mức giá cao nhất (của sản phẩm do “Trung Quoc” sản xuất).
select MASP, TENSP
from SANPHAM
where NUOCSX = 'Trung Quoc' and GIA in (select distinct top 3 GIA
										from SANPHAM
										where NUOCSX = 'Trung Quoc'
										order by GIA desc);

--31. * In ra danh sách khách hàng nằm trong 3 hạng cao nhất (xếp hạng theo doanh số).
select top 3 with ties MAKH, HOTEN, DOANHSO
from KHACHHANG
order by DOANHSO desc;

--32. Tính tổng số sản phẩm do “Trung Quoc” sản xuất.
select count(MASP) 'Tong so san pham do TQ'
from SANPHAM
where NUOCSX = 'Trung Quoc';

--33. Tính tổng số sản phẩm của từng nước sản xuất.
(select count(MASP) 'Tong so san pham', NUOCSX
from SANPHAM
where NUOCSX = 'Trung Quoc'
group by NUOCSX)
union
(select count(MASP), NUOCSX
from SANPHAM
where NUOCSX = 'Viet Nam'
group by NUOCSX)
union
(select count(MASP), NUOCSX
from SANPHAM
where NUOCSX = 'Thai Lan'
group by NUOCSX)
union
(select count(MASP), NUOCSX
from SANPHAM
where NUOCSX = 'Singapore'
group by NUOCSX);

--34. Với từng nước sản xuất, tìm giá bán cao nhất, thấp nhất, trung bình của các sản phẩm.
select NUOCSX, max(GIA) 'Gia ban cao nhat', min(GIA) 'Gia ban thap nhat', avg(GIA) 'Gia ban trung binh'
from SANPHAM
group by NUOCSX;

--35. Tính doanh thu bán hàng mỗi ngày.
select sum(TRIGIA) 'Doanh thu', NGHD
from HOADON
group by NGHD;

--36. Tính tổng số lượng của từng sản phẩm bán ra trong tháng 10/2006.
select sum(SL) 'So luong', sp.TENSP
from CTHD ct join SANPHAM sp on ct.MASP = sp.MASP
where SOHD in (select SOHD
				from HOADON
				where MONTH(NGHD) = 10 and year(NGHD) = 2006)
group by sp.TENSP;

--37. Tính doanh thu bán hàng của từng tháng trong năm 2006.
select sum(TRIGIA) 'Doanh thu tung thang', MONTH(NGHD) 'Thang'
from HOADON
where YEAR(NGHD) = 2006
group by MONTH(NGHD);

--38. Tìm hóa đơn có mua ít nhất 4 sản phẩm khác nhau.
select SOHD, count(distinct MASP) 'So san pham khac nhau'
from CTHD
group by SOHD
having count(distinct MASP) >= 4;

--39. Tìm hóa đơn có mua 3 sản phẩm do “Viet Nam” sản xuất (3 sản phẩm khác nhau).
select SOHD, count(distinct HD.MASP) 'So san pham khac nhau do Viet Nam sx'
from CTHD HD join SANPHAM SP on HD.MASP = SP.MASP
where SP.NUOCSX = 'Viet Nam'
group by HD.SOHD
having count(distinct HD.MASP) >= 3;

--40. Tìm khách hàng (MAKH, HOTEN) có số lần mua hàng nhiều nhất. 
select KH.MAKH, HOTEN, count(distinct HD.NGHD) 'So lan mua hang'
from KHACHHANG KH join HOADON HD on KH.MAKH = HD.MAKH
group by KH.MAKH, HOTEN
having count(distinct HD.NGHD) = (select top 1 with ties count(distinct NGHD) 'so lan'
									from HOADON
									group by MAKH
									order by 'so lan' desc);

--41. Tháng mấy trong năm 2006, doanh số bán hàng cao nhất ?
select month(NGHD) 'Thang', sum(TRIGIA) 'Doanh thu'
from HOADON
where year(NGHD) = '2006' 
group by month(NGHD)
having sum(TRIGIA) = (select top 1 with ties sum(TRIGIA) 'Doanh thu'
											from HOADON
											group by month(NGHD)
											order by 'Doanh thu' desc);

--42. Tìm sản phẩm (MASP, TENSP) có tổng số lượng bán ra thấp nhất trong năm 2006.
select ct.MASP, sp.TENSP, sum(ct.SL) 'So luong'
from CTHD ct join SANPHAM sp on ct.MASP = sp.MASP
				join HOADON hd on ct.SOHD = hd.SOHD
where year(hd.NGHD) = 2006
group by ct.MASP, sp.TENSP
having sum(ct.SL) = (select top 1 with ties sum(SL) 'So luong'
						from CTHD
						group by MASP
						order by 'So luong' asc);

--43. *Mỗi nước sản xuất, tìm sản phẩm (MASP,TENSP) có giá bán cao nhất.
select m.NUOCSX, MASP, TENSP
from (select NUOCSX, max(GIA) 'MAX'
		from SANPHAM
		group by NUOCSX) m join SANPHAM sp on sp.GIA = m.MAX
where m.NUOCSX = sp.NUOCSX;
 
--44. Tìm nước sản xuất sản xuất ít nhất 3 sản phẩm có giá bán khác nhau.
select NUOCSX 
from SANPHAM 
group by NUOCSX
having COUNT(DISTINCT GIA) > 2;

--45. *Trong 10 khách hàng có doanh số cao nhất, tìm khách hàng có số lần mua hàng nhiều 
--nhất
select *
from KHACHHANG
where MAKH IN (
	select top 1 MAKH
	from HOADON
	where MAKH IN (
		select top 10 MAKH
		from KHACHHANG
		order by DOANHSO desc
	)
	group by MAKH
	order by COUNT(SOHD) desc
);
