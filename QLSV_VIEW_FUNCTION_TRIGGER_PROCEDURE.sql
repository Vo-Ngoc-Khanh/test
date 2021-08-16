use QLSV
go
----tao view
/*51. 
a. Hiển thị danh sách gồm: MaSV, HoTen, MaLop, NgaySinh (dd/mm/yyyy), 
GioiTinh (Nam, Nữ), NamSinh của tất cả sinh viên. 
b. Tạo một view có tên là DSSV01 với nội dung truy vấn (câu a) ở trên. Mở cửa sổ 
Object Explorer, xem view vừa tạo lưu ở đâu? Xem kết quả dữ liệu từ View vừa tạo 
(SELECT * FROM DSSV01) và so sánh với kết quả ở câu a; có khác nhau không? 
Tại sao? */
SELECT*FROM SINHVIEN
--a
create view sinhvien51a
as
   select  MaSV,HoTen,MaLop,convert(varchar,NgaySinh,101) as NgaySinh,GioiTinh,NamSinh = year(NgaySinh)
   from SinhVien
--b
create view DSSV01
as  select * from sinhvien51a
   
select*from DSSV01
-->KET QUA GIONG NHAU
/*52. Thêm mới một sinh viên vào bảng sinh viên, sau đó dùng lệnh select * from 
sinhVien, kết quả có thay đổi so với câu 51b hay không? Tại sao?*/
insert into sinhvien values('10',N'Phan Thanh Nhã','CT12',N'Nữ','12/9/1991',N'Tuy Hòa')
select*from sinhvien
-->Ket qua 51b thay đổi theo bảng sinh viên
---tạo function
/*53. Viết hàm xếp loại dựa vào điểm như sau: Nếu Diem>=8 thì xếp loại “Giỏi”, Diem 
từ 7 đến 8 thì xếp loại “Khá”, Diem từ 5 đến 7 thì xếp loại TB, ngược lại thì “Yếu”. */
create function f_XepLoai_DiemHp(@diem float)
returns nvarchar(20) 
as
  begin
       declare @xl nvarchar(20);
			   set @xl = case
			   when @diem > = 8 then N'Giỏi'
			   when @diem > = 7 and @diem < 8 then N'Khá'
			   when @diem > = 5 and @diem < 7 then N'TB'
			   else N'Yếu'
			   end
      return @xl
  end
print dbo.f_xeploai_Diemhp ('10')
select Masv,round(avg(DIEMHP),0) as DiemTBC into BangDiemtbc
from DiemHP
group by  Masv
select MASV ,DIEMTBC, dbo.f_xeploai_Diemhp (diemtbc) as XepLoai from BangDiemtbc

/*54. Viết hàm tách tên từ chuỗi họ tên.
Sau đó tạo view hiển thị danh sách sinh viên gồm: MaSV, HoTen, MaLop, NgaySinh (dd/mm/yyyy), GioiTinh (Nam, Nữ) được sắp xếp theo thứ tự ưu tiên MaLop, Tên sinh viên. */
--function
--sử dụng hàm SUBSTRING(string, start, length)--string :chuỗi,start:vị trí tách chuỗi,length :độ dài chuỗi trả về
create function fn_TachTen_c54(@HoTen nvarchar(30))returns nvarchar(10) asbegin     declare @Ten nvarchar(10),@i int,@j int,@kt nvarchar(1),@LHoTen int;	 set @LHoTen = Len(@HoTen)	 set @i = 1;	 while @i<= @LHoTen	 begin	       set @kt = SUBSTRING(@HoTen,@i,1)		   if @kt = ' ' set @j = @i		   set @i=@i+1	 end	 set @Ten = SUBSTRING(@HoTen,@j+1,10)	 return @Tenendselect MaSV,HoTen,MaLop,convert(varchar,NgaySinh,101) as NgaySinh,GioiTinh,dbo.fn_TachTen_c54(HoTen) as Tenfrom sinhvien--view
-->Không thể tạo view có trường sắp xếp order by


--55. Viết hàm đọc điểm nguyên ra thành chữ tương ứng. 
create function fn_DocDiemNguyen_c55(@diem int)
returns nvarchar(10) as
begin
    declare @DiemChu nvarchar(10);
	set @DiemChu = case
	when @diem = 1 then N'một'
	when @diem = 2 then N'hai'
	when @diem = 3 then N'ba'
	when @diem = 4 then N'bốn'
	when @diem = 5 then N'năm'
	when @diem = 6 then N'sáu'
	when @diem = 7 then N'bảy'
	when @diem = 8 then N'tám'
	when @diem = 9 then N'chín'
	when @diem = 10 then N'mười'
	end
	return @DiemChu
end
select MASV ,DIEMTBC, dbo.fn_DocDiemNguyen_c55(diemtbc) as DiemChu from BangDiemtbc
--56. Viết hàm tính điểm trung bình chung của sinh viên có mã chỉ định ở học kỳ bất kỳ.
alter function fn_DiemTBC_C56(@masv int,@HocKy int)
returns float as
begin
     declare @diemtbc float;
	 set @diemtbc = (select round(avg(DIEMHP),1)
                    from DiemHP a, hocphan b
					where a.MaHP = b.MaHP and HocKy = @HocKy and MaSV = @masv
                    group by  Masv)
	return @diemtbc
end
print dbo.fn_DiemTBC_C56(5,1)

--57. Viết hàm tính tổng số đơn vị học trình của các học phần điểm < 5 của sinh viên có mã chỉ định. 
create function fn_C57(@masv int)
returns int as
begin
  declare @tong int;
  set @tong =(select sum(c.SoDVHT)
	          from diemhp b,hocphan c
	          where b.MaHP = c.MaHP and diemhp <5 and b.MaSV = @masv
	          group by b.masv)
  return @tong
end
print dbo.fn_c57('4')
/*60. Tạo thủ tục hiển thị danh sách gồm MaSV, HoTen, , MaLop, DiemHP, MaHP của 
những sinh viên có DiemHP nhỏ hơn số chỉ định, nếu không có thì hiển thị thông báo 
không có sinh viên nào.*/
alter proc usp_C60(@diem int)
as
begin
declare @kt int;
   set @kt = (select count(b.Masv)
              from sinhvien a,diemhp b
			  where a.masv = b.masv and diemhp <@diem)
   if(@kt >0)
   begin
	   select a.MaSV,HoTen,MaLop,diemhp,MaHP
	   from sinhvien a ,diemhp b
	   where a.MaSV = b.MaSV and diemhp < @diem 
   end
   else
   print N'Không có sinh viên nào'
   
end
exec usp_c60 1
/*61. Tạo thủ tục hiển thị Hoten sinh viên CHƯA học học phần có mã chỉ định, Kiểm 
tra Mã học phần chỉ định có trong danh mục không, Nếu không có thì hiển thị thông 
báo không có học phần này*/
create proc sp_61(@mahp int)
as
begin
   declare @kt int;
   set @kt = (select count(mahp) from hocphan where mahp = @mahp)
   if(@kt>0)
   begin
      select * from sinhvien where masv not in(select masv from diemhp where mahp = @mahp)
   end
   else
   print N'Không có học phần này'
end

exec sp_61 100
/*52. Tạo thủ tục hiển thị danh sách gồm: MaSV, HoTen, MaLop, NgaySinh 
(dd/mm/yyyy), GioiTinh (Nam, Nữ),Tuổi của những sinh viên có tuổi trong khoảng 
chỉ định. Nếu không có thì hiển thị thông báo không có sinh viên nào.*/
create proc sp_DSSVTheoTuoi(@begin int ,@end int)
as
begin
    declare @kt int;
	set @kt = (select count(masv) from sinhvien where (year(getdate())-year(NgaySinh)) >= @begin and (year(getdate())-year(NgaySinh)) <= @end )
	if(@kt>0)
	begin
		select MaSV,HoTen,MaLop,convert(varchar,NgaySinh,103) as NgaySinh,GioiTinh ,(year(getdate())-year(NgaySinh)) as Tuoi
		from sinhvien
		where (year(getdate())-year(NgaySinh)) >= @begin and (year(getdate())-year(NgaySinh)) <= @end
	end
	else
	 print N'Không có sinh viên nào'
end
exec sp_DSSVTheoTuoi 20,30
--53. Tạo thủ tục cho biết MaKhoa, Tên Khoa, tổng số sinh viên của Khoa chỉ định.Kiểm tra điều kiện Mã khoa có trong bảng danh mục không. 
create proc sp_53(@makhoa varchar(10))
as
begin
declare @kt int;
set @kt = (select count(*)from Khoa where MaKhoa = @makhoa)
if(@kt>0)
begin
select makhoa ,tenkhoa from khoa where makhoa = @makhoa
select count(masv) as TongSV
from khoa a,nganh b,lop c,sinhvien d
where a.MaKhoa = b.MaKhoa and b.MaNganh =c.MaNganh and c.MaLop = d.MaLop and a.MaKhoa = @makhoa
group by a.MaKhoa,TenKhoa
end
else
print N'Mã khoa không tồn tại'
end

exec sp_53 SP
/*54. Tạo thủ tục hiển thị MaLop,TenLop, Tổng số SV mỗi lớp của khoa có mã chỉ định, 
Kiểm tra điều kiện MaKhoa có trong bảng Danh mục không, Nếu không có thì hiển 
thị thông báo Không có lớp này. */
create proc sp_54(@makhoa varchar(10))
as
begin
declare @kt int;
set @kt = (select count(*)from Khoa where MaKhoa = @makhoa)
if(@kt>0)
begin
select malop ,tenlop from lop a,khoa b,nganh c where b.makhoa = @makhoa and a.MaNganh = c.MaNganh and b.MaKhoa = c.MaKhoa
select count(masv) as TongSV
from khoa a,nganh b,lop c,sinhvien d
where a.MaKhoa = b.MaKhoa and b.MaNganh =c.MaNganh and c.MaLop = d.MaLop and a.MaKhoa = @makhoa
group by c.malop,c.tenlop
end
else
print N'Mã khoa không tồn tại'
end

exec sp_53 cntt
--55. Tạo thủ tục tính điểm trung bình chung từng học kỳ theo từng sinh viên của lớp có mã chỉ định.
create proc sp_55(@malop varchar(5))
as
begin
    select HoTen,a.MaLop, round(avg(diemhp),1) diemtbc
	from sinhvien a,diemhp b,lop c
	where a.masv = b.masv and a.malop = c.malop and a.MaLop = @malop
	group by b.masv,HoTen,a.MaLop
end
exec sp_55 ct13
/*56. Tạo thủ tục hiển thị danh sách gồm: MaSV, HoTen, MaLop, MaKhoa, NgaySinh 
(dd/mm/yyyy),GioiTinh (Nam, Nữ) của những sinh viên ở Khoa có mã chỉ định, Nếu 
không có thì hiển thị thông báo Không có sinh viên nào. */
create proc sp_56(@makhoa varchar(5))
as
begin
select a.MaSV,HoTen,a.MaLop,c.MaKhoa,convert(varchar,NgaySinh,103) as NgaySinh,GioiTinh
from sinhvien a,lop b,nganh c,khoa d
where a.MaLop = b.MaLop and b.MaNganh = c.MaNganh and c.MaKhoa =d.MaKhoa and c.MaKhoa = @makhoa
end

exec sp_56 cntt
/*57. Tạo thủ tục cho biết Hoten sinh viên KHÔNG có điểm HP <5 ở lớp có mã chỉ 
định, Kiểm tra Mã lớp chỉ định có trong danh mục không, Nếu không thì hiển thị 
thông báo. */
create proc sp_57(@malop varchar(5))
as
begin
declare @kt int;
set @kt = (select count(*) from Lop where MaLop = @malop)
if(@kt>0)
begin
select distinct HoTen
from sinhvien a,lop b
where a.MaLop = b.MaLop and a.MaLop =@malop and a.masv not in(select distinct masv from diemhp where diemhp < 5)
end
else
print N'Không có mã lớp này'
end

exec sp_57 ct13
/*58. Tạo thủ tục hiển thị danh sách gồm: MaSV, HoTen, MaLop, NgaySinh 
(dd/mm/yyyy), GioiTinh(Nam, Nữ), của những sinh viên học lớp có mã chỉ định. 
Kiểm tra MaLop chỉ định có tồn tại trong bảng không, nếu không có thì hiển thị thông 
báo Không có lớp đó.*/
create proc sp_58(@malop varchar(5))
as
begin
declare @kt int;
set @kt = (select count(*) from Lop where MaLop = @malop)
if(@kt>0)
begin
select distinct masv,hoten,a.malop,convert(varchar,NgaySinh,103) as NgaySinh,GioiTinh
from sinhvien a,lop b
where a.MaLop = b.MaLop and a.MaLop =@malop 
end
else
print N'Không có mã lớp này'
end

exec sp_58 ct13

--Tạo trigger
/*62. Tạo một Trigger để kiểm tra tính hợp lệ của dữ liệu được nhập vào một bảng 
SINHVIEN là dữ liệu MaSV là không rỗng. */
create trigger tg_SinhVien_insert
on SinhVien
for insert
as
begin
    declare @kt int;
	set @kt =(select masv from inserted)
	if (@kt =' ')
	begin
	    print N'MaSV rỗng,Vui lòng điền MaSV'
		rollback transaction
	end
end
--test
insert into sinhvien values('',N'Trần Thị Hoa','CT11',N'Nữ','9/8/1994',N'Hoài Nhơn')


/*63. Thực hiện việc kiểm tra rằng buộc khoá ngoại trong bảng SINHVIEN là mã lớp 
phải tồn tại trong bảng DMLOP.*/
create trigger tg_SinhVien_MaLop_insert
on SinhVien
for insert
as
begin
   if not exists(select *from lop a,inserted b where a.MaLop = b.malop)
	begin
	  print N'Mã lớp không tồn tại trong bảng Lớp'
	  rollback tran
	end
end
insert into sinhvien values('10',N'Trần Thị Hoa','CTRRR',N'Nữ','9/8/1994',N'Hoài Nhơn')

/*64. Tạo một Trigger khi thêm một sinh viên trong bảng SINHVIEN ở một lớp nào đó 
thì cột Siso của lớp đó trong bảng LOP tự động tăng lên 1, đảm bảo tính toàn ven dữ 
liệu khi thêm một sinh viên mới trong bảng SINHVIEN thì sinh viên đó phải có mã 
lớp trong bảng LOP, đảm bảo tính toàn vẹn dữ liệu khi thêm là mã lớp phải có trong 
bảng LOP.*/
alter table Lop add siso int default 0;
create trigger tg_SinhVien_MaLop_insert
on SinhVien
for insert
as
begin
   if not exists(select *from lop a,inserted b where a.MaLop = b.malop)
	begin
	  print N'Mã lớp không tồn tại trong bảng Lớp'
	  rollback tran
	end
    else
	update lop set siso =siso+1 from lop a,inserted b where  a.MaLop = b.MaLop
end
---
insert into sinhvien values('14',N'Trần Thị Hoa','CT12',N'Nữ','9/8/1994',N'Hoài Nhơn')
insert into sinhvien values('15',N'Trần Thị Hoa','CT12',N'Nữ','9/8/1994',N'Hoài Nhơn')
insert into sinhvien values('16',N'Trần Thị Hoa','CT12',N'Nữ','9/8/1994',N'Hoài Nhơn')
---
--65. Tạo một Trigger không cho phép xoá các sinh viên ở lớp CT12. 
create trigger tg_SV_delete
on sinhvien
for delete
as
begin
	if exists (select *from deleted b where MaLop = 'CT12')
	begin
	   print N'Không thể xóa sinh viên lớp CT12'
	   ROLLBACK TRAN
	end
end

delete from sinhvien where masv = 14
--66. Tạo một Trigger không cho phép xoá nhiều hơn 2 lớp trong bảng LOP 
create trigger tg_lop_delete
on Lop
for delete
as
 begin
    declare @kt int;
	set @kt =(select count(malop) from deleted)
	if(@kt>2)
	begin
	  print N'Không thể xóa nhiều hơn 2 lớp'
	  rollback tran
	end
 end
 --test
 delete from lop where malop in ('ct14','ct17')
insert into lop values('CT14',N'Cao đẳng tin học','480202',11,'TC',2013,0)
insert into lop values('CT15',N'Cao đẳng tin học','480202',12,'CĐ',2013,0)
insert into lop values('CT16',N'Cao đẳng tin học','480202',13,'CĐ',2014,0)
insert into lop values('CT17',N'Cao đẳng tin học','480202',13,'CĐ',2014,0)
/*67. Tạo một Trigger sao cho khi xóa một sinh viên mới từ bảng SINHVIEN thì SiSo 
của lớp tương ứng trong bảng LOP tự động giảm xuống 1. */
alter trigger tg_sv_delete_siso
on sinhvien
for delete
as
 begin
 declare @kt int,@dem int;
 set @kt = (select count(*) from deleted)
 set @dem =1;
 while @dem < =@kt
 begin
    update lop set siso = siso -1 from lop a,deleted b where  a.MaLop = b.MaLop
	set @dem = @dem+1
 end
 end
delete from sinhvien where masv in ('19')
insert into sinhvien values('19',N'Trần Thị Hoa','CT11',N'Nữ','9/8/1994',N'Hoài Nhơn')
insert into sinhvien values('20',N'Trần Thị Hoa','CT11',N'Nữ','9/8/1994',N'Hoài Nhơn')
select*from lop
--68. Tạo một Trigger kiểm tra điều kiện cho cột Điểm là <=10 
create trigger tg_Diemhp_insert
on DiemHP
for insert,update
as
begin
   if exists (select diemhp from inserted where diemhp >10)
   begin
   print N'Điểm nhập vào >10 nên không hợp lệ'
   rollback tran
   end
   else if exists (select diemhp from inserted where diemhp <0)
   begin
   print N'Điểm nhập vào <0 nên không hợp lệ'
   rollback tran
   end

end
select*from diemhp
update diemhp set diemhp = 77 where masv = 2 and mahp =2
--69. Tạo Trigger bẫy lỗi cho khoá ngoại của bảng SINHVIEN khi chỉnh sửa. 
create trigger tg_SV_KhoaNgoai
on SinhVien
for update,insert
as
begin
    if not exists(select b.MaLop from lop a,inserted b where a.MaLop = b.MaLop)
	begin
	 Print N'Mã lớp không tồn tại'
	 rollback tran
	end
end

update sinhvien set malop ='ct111' where masv =1
/*70. Tạo ra Trigger sao cho khi cập nhật MaLop một sinh viên trong bảng SINHVIEN 
thì SiSo của lớp tương ứng trong bảng LOP tự động thay đổi. */
create trigger tg_1SV_SISO_update
on SinhVien
for update
as
   begin
   update Lop set siso =siso-1 from Lop a,deleted b where a.MaLop = b.MaLop
   update lop set siso = siso+1 from lop a ,inserted b where a.MaLop = b.MaLop
   end
update sinhvien set malop ='ct12' where masv = 14
select count(masv),malop from sinhvien group by malop
select*from lop

update lop set siso = 6 where malop = 'ct13'
/*71. Hãy tạo ra Trigger sao cho khi sửa MaLop những sinh viên trong bảng 
SINHVIEN thì SiSo của lớp tương ứng trong bảng DMLOP tự động thay đổi.*/
alter trigger tg_1SV_SISO_update
on SinhVien
for update
as
begin
   declare @kt int,@dem int
   set @dem = (select count(*) from deleted)
   set @kt = 1
   while @kt <= @dem
   begin
   update Lop set siso =siso-1 from Lop a,deleted b where a.MaLop = b.MaLop
   update lop set siso = siso+1 from lop a ,inserted b where a.MaLop = b.MaLop
   set @kt+=1
   
   end
end

update sinhvien set malop ='ct11' where masv in ('14','15','16')
select count(masv),malop from sinhvien group by malop
select*from lop


---
select*from sinhvien
select*from diemhp
select*from hocphan
select*from lop
select*from khoa
select*from nganh










