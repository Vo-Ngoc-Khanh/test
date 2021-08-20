create database QLPHSach
go
use QLPHSach
go
create table TacGia
(
	MaTG char(5) primary key,
	HoTen nvarchar(20) ,
	DiaChi nvarchar(50) ,
	NgaySinh date,
	SoDT varchar(15) 
)
create table Sach
(
	MaSach char(5) primary key,
	TenSach nvarchar(30) ,
	TheLoai nvarchar(30) 
)
go
create table TG_Sach
(
	MaTG char(5) not null,
	MaSach char(5) not null,
	primary key (MaTG,MaSach),
	foreign key (MaTG) references TacGia(MaTG),
	foreign key (MaSach) references Sach(MaSach)
)
go
create table PhatHanh
(
	MaPH char(8) ,
	MaSach char(5),
	MaTG char(5),
	NgayPH date default getdate(),
	SoLuong int,
	NhaXuatBan nvarchar(50),
	primary key (MaPH,MaSach),
	foreign key (MaTG) references TacGia(MaTG),
	foreign key (MaSach) references Sach(MaSach)
)
go


insert into Sach values ('MS001',N'Hiểu về trái tim',N'Tâm lý')
insert into Sach values ('MS002',N'Mã hóa và mật mã',N'Khoa học')
insert into Sach values ('MS003',N'Cơ sở toán học',N'Giáo khoa')
insert into Sach values ('MS004',N'Tiếng anh thực dụng',N'Giáo khoa')
insert into Sach values ('MS005',N'Hạnh phúc là gì',N'Tâm lý')
insert into Sach values ('MS006',N'Toán cao cấp',N'Giáo Khoa')
go
set dateformat dmy
go
insert into TacGia values ('TG001',N'Minh Niệm',N'Quận 1, TP HCM','12/5/1968','98989890')
insert into TacGia values ('TG002',N'Trần Đan Thư',N'02 Trần Nhân Tông, Quận 9, TP HCM','15/3/1964','98123456')
insert into TacGia values ('TG003',N'Lê Hoài Bắc',N'CC 12 Lê Văn Tám, Quận Tân Bình, TP HCM','12/12/1970','97123452')
insert into TacGia values ('TG004',N'Ngô Tống Minh Đạt',N'CC Nguyễn Cư Trinh, Quận 1, TP HCM','7/3/1996','91212343')
go
insert into PhatHanh values ('PH210124','MS001','TG001','24/01/2021','1000',N'Thanh niên')
insert into PhatHanh values ('PH210726','MS002','TG002','26/7/2021','1500',N'Giáo dục')
insert into PhatHanh values ('PH210908','MS003','TG002','8/9/2021','3000',N'Giáo dục')
insert into PhatHanh values ('PH210416','MS004','TG004','16/4/2021','1500',N'Kim Đồng')
insert into PhatHanh values ('PH210412','MS005','TG001','12/4/2021','4500',N'Giáo dục')
insert into PhatHanh values ('PH211212','MS006','TG003','12/12/2021','1200',N'Giáo dục')
--cau 1.
--Ngày phát hành là ngày hiện tại của hệ thống
alter table phathanh
add constraint rb_ngayphathanhmacdinh
default getdate() for ngayph
--trigger: Ngày phát hành sách phải lớn hơn ngày sinh của tác giả.
create trigger tg_PhatHanh
on Phathanh
for insert, update
as
begin
	declare @NgayPH date, @NgaySinh date;
	set @NgayPH = (select NgayPH from inserted )
	set @NgaySinh = (select NgaySinh from Inserted a, TacGia b where a.MaTG = b.MaTG)
	if(@NgayPH<=@NgaySinh)
	begin
			print 'Ngày phát hành không được sau ngày sinh của tác giả này'
			rollback transaction
	end
end
--2. Tạo khung nhìn danh sách những quyển sách được phát hành bởi nhà xuất bản “Giáo dục”.
create view v_SachGiaoDuc
as
  select a.MaSach 'Mã sách',TenSach 'Tên sách',NhaXuatBan 'Nhà Xuất Bản'
  from Sach a,PhatHanh b
  where a.MaSach = b.MaSach and NhaXuatBan like N'Giáo dục'
select*from v_SachGiaoDuc
go
--3. Tạo khung nhìn cho biết danh sách MaTG, TenTG, SDT của những quyển sách thuộc loại “Giáo khoa”.
create view v_sachgiaokhoa as
select a.matg, b.hoten as tentg, b.sodt as sdt
from phathanh a, tacgia b, sach c
where a.matg = b.matg and a.masach = c.masach and c.theloai=N'Giáo khoa'
select * from v_sachgiaokhoa
--4.Cho biết nhà xuất bản phát hành nhiều sách nhất.
--cách 1
select TOP 1 NhaXuatBan,Count(MaSach) as SLSach
from PhatHanh
group by NhaXuatBan
order by count(MaSach) desc
--cách 2
select NhaXuatBan,count(MaSach) as SLSach
from PhatHanh
group by NhaXuatBan
having Count(MaSach) >= all (select count(MaSach) from PhatHanh group by NhaXuatBan)
--5. Cho biết tác giả có số lượng sách được phát hành nhiều nhất.
--cách 1
select top 1 a.MaTG,HoTen,sum(SoLuong) as SLSach
from TacGia a,PhatHanh b
where a.MaTG = b.MaTG 
group by a.MaTG,HoTen
order by sum(SoLuong) desc
--cách 2
select  a.MaTG,HoTen,sum(SoLuong) as SLSach
from TacGia a,PhatHanh b
where a.MaTG = b.MaTG 
group by a.MaTG,HoTen
having sum(SoLuong) >= ALL (select sum(SoLuong) from PhatHanh group by MaTG)

--6. Viết hàm tự động sinh mã sách.
--Mã sách gồm 5 ký tự, trong đó 2 ký tự đầu là MS, 3 ký tự sau là theo số thứ tự. VD: MS001,MS002,...
--Viết đoạn batch chèn thêm dữ liệu vào bảng Sách sử dụng hàm tự động sinh mã ở trên.
create function auto_masach()
returns char(5)
as
begin
	declare @masach char(5), @stt int, @tam char(3)
	select @stt = count(masach) from sach
	set @stt = @stt +1;
	set  @tam =
	case
			when (@stt between 0 and 9) then '00' + CONVERT(char(1), @stt)
			when @stt between 10 and 99 then '0' + CONVERT(char(2), @stt)
	else
		'00'
	end
		set @masach = 'MS' + @tam		
	return @masach
end

--test
print dbo.auto_masach()
insert into Sach values (dbo.auto_masach(),N'Không biết',N'Không biết')
select * from sach
delete from sach where MaSach = 'MS'
--7
/*7. Viết hàm tự động sinh Mã phát hành.
Mã phát hành gồm 8 ký tự, trong đó 2 ký tự đầu là “PH”, 2 ký tự tiếp theo là 2 số cuối năm, 2 ký tự tiếp theo là tháng, 2 ký tự cuối là ngày phát hành. VD: PH210423 (21 là 2 số cuối của năm 2021, với 04 là tháng 4, 23 là ngày).
Viết đoạn batch chèn thêm dữ liệu vào bảng PhatHanh sử dụng hàm tự động sinh mã ở trên.
*/
create FUNCTION AUTO_IDMaPH()
RETURNS VARCHAR(8)
AS
BEGIN
	DECLARE @ID int, @kq VARCHAR(8) , @d int, @m int, @y int
	set @d = day(getdate())
	set @m = MONTH(getdate())
	set @y = year(getdate())
	set @kq = 'PH' + convert(varchar(2),@y%100) + convert(varchar(2),@m) +convert(varchar(2),@d)   
	RETURN @kq
END
print dbo.AUTO_IDMaPH()
set dateformat dmy
insert into PhatHanh values(dbo.AUTO_IDMaPH(),'MS001','TG001','18/08/2021',100,N'Thanh Niên')
--7b. Tạo mã PH tự động nhưng có thêm số tt khi thêm mới, Mã PH có 11 ký tự
--vd: PH210818007 (3 ký tự cuối là stt)
create FUNCTION AUTO_IDMaPH_NangCao()
RETURNS VARCHAR(11)
AS
BEGIN
	DECLARE @ID int, @kq VARCHAR(8) , @d int, @m int, @y int, @stt char(3)
	set @d = day(getdate())
	set @m = MONTH(getdate())
	set @y = year(getdate())
	set @id = (select count(MaPH) from PhatHanh)
	if @id<10  
		set @stt = '00'+convert(char(1),@id)
	else
	begin
		if @id between 10 and 99 
			set @stt = '0'+convert(char(2),@id)
		else set @stt = '000'
	end
	set @kq = 'PH' + convert(varchar(2),@y%100) + convert(varchar(2),@m) +convert(varchar(2),@d)  +@stt 
	RETURN @kq
END
print dbo.AUTO_IDMaPH_NangCao()
--8
--8.Viết trigger để ràng buộc mỗi nhà xuất bản không được phát hành nhiều hơn 1 cuốn sách mỗi ngày (thêm, cập nhật) trong bảng PhatHanh.
alter trigger tg_PhatHanh_NXB
on PhatHanh
for update,insert
as
begin
	declare @ngayph date, @nhaxb nvarchar(30),@ms char(5)
	set @ngayph =  (select ngayph from inserted)
	set @nhaxb =  (select nhaxuatban from inserted)
	set @ms =   (select MaSach from inserted)
	if (select count(*) from phathanh where ngayph = @ngayph and nhaxuatban=@nhaxb and MaSach = @ms)>1
		begin
			print N'1 mã sách trong 1 ngày một nhà xuất bản chỉ được phát hành 1 lần'
			rollback transaction
		end
end

--test
set dateformat dmy
insert into PhatHanh values('PH210102','MS001','TG001','15/4/2021','4',N'Giáo dục')

select * from Sach
select * from TacGia
select * from TG_Sach
select * from PhatHanh order by NgayPH
delete from phathanh
