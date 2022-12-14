set nocount on
if exists (select * from SysObjects where name='spGetTableList' and type='P') 
	drop proc spGetTableList
go
create proc spGetTableList
	@arrTables cursor varying output 
as begin 
	set @arrTables = cursor for
		select table_name
		from Information_Schema. TABLES
		where table_type='BASE TABLE'
		--and table_name <> 'dtproperties'
	open @arrTables
end
go

if exists (select * from SysObjects where name='spGetFKList' and type='P') 
	drop proc spGetFKList
go
create proc spGetFKList
	@arrFKs cursor varying output 
as begin 
	set @arrFKs = cursor for
		select constraint_name, table_name
		from Information_Schema. TABLE_CONSTRAINTS
		where constraint_type='FOREIGN KEY'
	open @arrFKs
end
go
-----------------------------------------------------------------------------------------------
-- đoạn này dùng để lấy tên table và fk để drop các constraints
if exists (select * from SysObjects where name='spClearFKs' and type='P') 
	drop proc spClearFKs
go
create proc spClearFKs
	@dbName varchar(66)
as begin
	--save db hiện hành
	declare @curDB varchar(66)
	set @curDB=db_name() 
		
	if (@dbName is null) or (@dbName='') begin
		set @dbName=db_name()
	end
	if @dbName in ('master') begin
		raisError ('Không thể xóa object(s) hệ thống!',16,1)
		return -1
	end
	
	--db_name() này ở đâu ra vậy , có phải là hàm có sẵn ko ? 
	----La` ha`m co' san~
	--chuyen de'n db muo'n xoa'
	declare @sc nvarchar(333)
	
	set @sc='use '+@dbName
	exec sp_executeSQL @sc

	--lấy ds các FK & bảng chứa chúng
	declare @c cursor 
	exec spGetFKList @c output
	--thực hiện xóa FK
	declare @tableName varchar(66), @fkName varchar(66)
	fetch next from @c into @fkName, @tableName
	while @@fetch_status=0 begin
		set @sc='alter table '+@tableName+' drop constraint '+ @fkName
		exec sp_executeSQL @sc

		fetch next from @c into @fkName, @tableName
	end
	close @c
	deallocate @c
	--
	set @sc='use '+@curDB
	exec sp_executeSQL @sc
end
go
-----------------------------------------------------------------------------------------------
--Đoạn này để drop table
if exists (select * from SysObjects where name='spClearTables' and type='P')
	drop proc spClearTables
go
create proc spClearTables
	@dbName varchar(66)
as begin
	declare @curDB varchar(66)
	set @curDB=db_name()
	--
	declare @sc nvarchar(333)

	if (@dbName is null) or (@dbName='') begin
		set @dbName=db_name()
	end
	if @dbName in ('master') begin
		raisError ('Không thể xóa object(s) hệ thống!',16,1)
		return -1
	end
		
	set @sc='use '+@dbName
	exec sp_executeSQL @sc
	--		
	declare @c cursor 
	exec spGetTableList @c output

	declare @tableName varchar(66)
	fetch next from @c into @tableName
	while @@fetch_status=0 begin
		set @sc='drop table '+@tableName
		exec sp_executeSQL @sc
		
		fetch next from @c into @tableName
	end
	close @c
	deallocate @c
	--
	set @sc = 'use '+@curDB
	exec sp_executeSQL @sc
	--
	return 0
end
go
-----------------------------------------------------------------------------------------------
--doạn này drop db
if exists (select * from SysObjects where name='spClearDB' and type='P')   --type ='P' or 'U' là gì vậy
	drop proc spClearDB
go
create proc spClearDB
	@dbName varchar(66)
as begin
	declare @curDB varchar(66)
	set @curDB=db_name()
	--	
	if (@dbName is null) or (@dbName='') begin
		set @dbName=db_name()
	end

	if @dbName in ('master') begin
		raisError ('Không thể xóa object(s) hệ thống!',16,1)
		return -1
	end
	--
	exec spClearFKs @dbName
	exec spClearTables @dbName
	--
	declare @sc nvarchar(333)
	set @sc = 'use '+@curDB
	exec sp_executeSQL @sc
	--
	return 0
end
go
exec spClearDB ''
go

create database QLDT_week#4_5_6_7
go
use QLDT_week#4_5_6_7
go
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
create table GIAOVIEN 
(
	MAGV char (5), 
	HOTEN nvarchar(40), 
	LUONG float, 
	PHAI nchar(3), 
	NGSINH datetime, 
	DIACHI nvarchar(100), 
	GVQLCM char(5), 
	MABM nchar(5)
	PRIMARY KEY (MAGV)
)

create table GV_DT 
(
	MAGV char(5), 
	DIENTHOAI char(12),
	PRIMARY KEY (MAGV, DIENTHOAI)
)

create table BOMON 
(
	MABM nchar(5),
	TENBM nvarchar(40), 	 
	PHONG char(5),
	DIENTHOAI char(12), 
	TRUONGBM char(5), 
	MAKHOA char(4), 	
	NGAYNHANCHUC datetime,
	PRIMARY KEY (MABM)
)
create table KHOA 
(
	MAKHOA char(4), 
	TENKHOA nvarchar(40), 
	NAMTL int, 
	PHONG char(5), 
	DIENTHOAI char(12), 	
	TRUONGKHOA char(5), 
	NGAYNHANCHUC datetime,
	PRIMARY KEY (MAKHOA)	
)

create table DETAI 
(
	MADT char(3), 
	TENDT nvarchar(100), 
	CAPQL nvarchar(40), 
	KINHPHI float, 
	NGAYBD datetime, 
	NGAYKT datetime, 	
	MACD nchar(4),
	GVCNDT char(5), 	
	PRIMARY KEY (MADT)
)

create table CHUDE 
(
	MACD nchar(4), 
	TENCD nvarchar(50),
	PRIMARY KEY (MACD)
)
create table CONGVIEC 
(
	MADT char(3), 
	SOTT int, 
	TENCV nvarchar(40), 
	NGAYBD datetime, 
	NGAYKT datetime,
	PRIMARY KEY (MADT, SOTT) 
)

create table THAMGIADT 
(
	MAGV char(5), 
	MADT char(3), 
	STT int, 
	PHUCAP float , 
	KETQUA nvarchar(40),
	PRIMARY KEY (MAGV, MADT, STT)
)

create table NGUOITHAN 
(
	MAGV char(5), 
	TEN nvarchar(20), 
	NGSINH datetime, 
	PHAI nchar(3),
	PRIMARY KEY (MAGV, TEN)
)

alter table GIAOVIEN add
	constraint FK_GIAOVIEN_BOMON foreign key (MABM) references BOMON (MABM),
	constraint FK_GIAOVIEN_GIAOVIEN foreign key (GVQLCM) references GIAOVIEN (MAGV)

alter table KHOA add 
	constraint FK_KHOA_GIAOVIEN foreign key (TRUONGKHOA) references GIAOVIEN (MAGV)

alter table BOMON add 
	constraint FK_BOMON_KHOA foreign key (MAKHOA) references KHOA(MAKHOA),
	constraint FK_BOMON_GIAOVIEN foreign key (TRUONGBM) references GIAOVIEN (MAGV)

alter table NGUOITHAN add
	constraint FK_NGUOITHAN_GIAOVIEN foreign key (MAGV)references GIAOVIEN (MAGV)

alter table THAMGIADT add
	constraint FK_PHANCONG_GIAOVIEN foreign key (MAGV)references GIAOVIEN (MAGV),
	constraint FK_PHANCONG_CONGVIEC foreign key (MADT, STT)references CONGVIEC(MADT, SOTT)

alter table DETAI add
	constraint FK_DETAI_CHUDE foreign key (MACD)references CHUDE (MACD)

alter table DETAI add
	constraint FK_DETAI_GIAOVIEN foreign key (GVCNDT)references GIAOVIEN (MAGV)

alter table GV_DT add
	constraint FK_DIENTHOAI_GIAOVIEN foreign key (MAGV)references GIAOVIEN (MAGV)

alter table CONGVIEC add 	
	constraint FK_CONGVIEC_DETAI foreign key (MADT)references DETAI (MADT)
----------------
insert into KHOA values ('CNTT',N'Công nghệ thông tin',1995,'B11','0838123456',null,'02/20/2005')
insert into KHOA values ('VL',N'Vật lý',1976,'B21','0838223223',null,'09/18/2003')
insert into KHOA values ('SH',N'Sinh học',1980,'B31','0838454545',null,'10/11/2000')
insert into KHOA values ('HH',N'Hóa học',1980,'B41','0838456456',null,'10/15/2001')
----------------
insert into BOMON values (N'HTTT',N'Hệ thống thông tin','B13','0838125125',null,'CNTT','09/20/2004')
insert into BOMON values (N'CNTT',N'Công nghệ tri thức','B15','0838126126',null, 'CNTT', null)
insert into BOMON values (N'MMT',N'Mạng máy tính','B16','0838676767 ',null,'CNTT','05/15/2005')
insert into BOMON values (N'VLĐT',N'Vật lý điện tử','B23','0838234234',null, 'VL', null)	
insert into BOMON values (N'VLƯD',N'Vật lý ứng dụng','B24','0838454545',null,'VL','02/18/2006')
insert into BOMON values (N'VS',N'Vi sinh','B32','0838909090',null,'SH','01/01/2007')
insert into BOMON values (N'SH',N'Sinh hóa','B33','0838898989',null, 'SH', null)	
insert into BOMON values (N'HL',N'Hóa lý','B42','0838878787',null, 'HH', null)	
insert into BOMON values (N'HPT',N'Hóa phân tích','B43','0838777777',null,'HH','10/15/2007')
insert into BOMON values (N'HHC',N'Hóa hữu cơ','B44','838222222',null, 'HH', null)	
----------------
insert into GIAOVIEN values ('001',N'Nguyễn Hoài An',2000,N'Nam','02/15/1973',N'25/3 Lạc Long Quân, Q.10, TP HCM', null, N'MMT')
insert into GIAOVIEN values ('002',N'Trần Trà Hương',2500,N'Nữ','06/20/1960',N'125	Trần Hưng Đạo, Q.1,TP HCM', null, N'HTTT')
insert into GIAOVIEN values ('003',N'Nguyễn Ngọc Ánh',2200,N'Nữ','05/11/1975',N'12/21	Võ Văn Ngân	Thủ Đức, TP HCM', '002',N'HTTT')
insert into GIAOVIEN values ('004',N'Trương Nam Sơn',2300,N'Nam','06/20/1959',N'215	Lý Thường Kiệt,TP Biên Hòa',null, N'VS')
insert into GIAOVIEN values ('005',N'Lý Hoàng Hà',2500,N'Nam','10/23/1954',N'22/5	Nguyễn Xí, Q.Bình Thạnh, TP HCM',null, N'VLĐT')
insert into GIAOVIEN values ('006',N'Trần Bạch Tuyết',1500,N'Nữ','05/20/1980',N'127	Hùng Vương, TP Mỹ Tho','004',N'VS')
insert into GIAOVIEN values ('007',N'Nguyễn An Trung',2100,N'Nam','06/05/1976',N'234 3/2, TP Biên Hòa',null, N'HPT')
insert into GIAOVIEN values ('008',N'Trần Trung Hiếu',1800,N'Nam','08/06/1977',N'22/11 Lý Thường Kiệt, TP Mỹ Tho','007',N'HPT')
insert into GIAOVIEN values ('009',N'Trần Hoàng Nam',2000,N'Nam','11/22/1975',N'234	Trấn Não, An Phú,TP HCM','001',N'MMT')
insert into GIAOVIEN values ('010',N'Phạm Nam Thanh',1500,N'Nam','12/12/1980',N'221	Hùng Vương, Q.5, TP HCM','007',N'HPT')
----------------
insert into GV_DT values ('001','0903123123')
insert into GV_DT values ('001','0838912112')
insert into GV_DT values ('002','0913454545')
insert into GV_DT values ('003','0903656565')
insert into GV_DT values ('003','0838121212')
insert into GV_DT values ('003','0937125125')
insert into GV_DT values ('006','0937888888')
insert into GV_DT values ('008','0913232323')
insert into GV_DT values ('008','0653717171')
----------------
insert into CHUDE values (N'QLGD',N'Quản lý giáo dục')
insert into CHUDE values (N'NCPT',N'Nghiên cứu phát triển')
insert into CHUDE values (N'ƯDCN',N'Ứng dụng công nghệ')
----------------
insert into DETAI (MADT, TENDT, KINHPHI, CAPQL, NGAYBD, NGAYKT, MACD, GVCNDT) values ('001',N'HTTT quản lý các trường ĐH',20,N'ĐHQG','10/20/2007','10/20/2008',N'QLGD','002')
insert into DETAI (MADT, TENDT, KINHPHI, CAPQL, NGAYBD, NGAYKT, MACD, GVCNDT) values ('002',N'HTTT quản lý giáo vụ cho một Khoa','20',N'Trường','10/12/2000','10/12/2001',N'QLGD','002')
insert into DETAI (MADT, TENDT, KINHPHI, CAPQL, NGAYBD, NGAYKT, MACD, GVCNDT) values ('003',N'Nghiên cứu chế tạo sợi Nanô Platin','300',N'ĐHQG','05/15/2008','05/15/2010',N'NCPT','005')
insert into DETAI (MADT, TENDT, KINHPHI, CAPQL, NGAYBD, NGAYKT, MACD, GVCNDT) values ('004',N'Tạo vật liệu sinh học bằng màng ối người','100',N'Nhà nước','01/01/2007','12/31/2009',N'NCPT','004')
insert into DETAI (MADT, TENDT, KINHPHI, CAPQL, NGAYBD, NGAYKT, MACD, GVCNDT) values ('005',N'Ứng dụng hóa học xanh','200',N'Trường','10/10/2003','12/10/2004',N'ƯDCN','007')
insert into DETAI (MADT, TENDT, KINHPHI, CAPQL, NGAYBD, NGAYKT, MACD, GVCNDT) values ('006',N'Nghiên cứu tế bào gốc','4000',N'Nhà nước','10/20/2006','10/20/2009',N'NCPT','004')
insert into DETAI (MADT, TENDT, KINHPHI, CAPQL, NGAYBD, NGAYKT, MACD, GVCNDT) values ('007',N'HTTT quản lý thư viện ở các trường ĐH','20',N'Trường','5/10/2009','05/10/2010',N'QLGD','001')
----------------
set dateformat dmy

insert into CONGVIEC values ('001',1,N'Khởi tạo và Lập kế hoạch','20/10/2007','20/12/2008')
insert into CONGVIEC values ('001',2,N'Xác định yêu cầu','21/12/2008','21/03/2008')
insert into CONGVIEC values ('001',3,N'Phân tích hệ thống','22/03/2008','22/5/2008')
insert into CONGVIEC values ('001',4,N'Thiết kế hệ thống','23/05/2008','23/06/2008')
insert into CONGVIEC values ('001',5,N'Cài đặt thử nghiệm','24/06/2008','20/10/2008')
insert into CONGVIEC values ('006',1,N'Lấy mẫu','20/10/2006','20/02/2007')
insert into CONGVIEC values ('006',2,N'Nuôi cấy','21/02/2007','21/08/2008')
insert into CONGVIEC values ('002',1,N'Khởi tạo và Lập kế hoạch','10/05/2009','10/07/2009')
insert into CONGVIEC values ('002',2,N'Xác định yêu cầu','11/07/2009','11/10/2009')
insert into CONGVIEC values ('002',3,N'Phân tích hệ thống','12/10/2009','20/12/2009')
insert into CONGVIEC values ('002',4,N'Thiết kế hệ thống','21/12/2009','22/03/2010')
insert into CONGVIEC values ('002',5,N'Cài đặt thử nghiệm','23/03/2010','10/05/2010')
set dateformat mdy
----------------
insert into THAMGIADT values ('003','001',1,1,N'Đạt')
insert into THAMGIADT values ('003','001',2,0,N'Đạt')
insert into THAMGIADT values ('002','001',4,2,N'Đạt')
insert into THAMGIADT values ('003','001',4,1,N'Đạt')
insert into THAMGIADT values ('004','006',1,0,N'Đạt')
insert into THAMGIADT values ('004','006',2,1,N'Đạt')
insert into THAMGIADT values ('006','006',2,1.5,N'Đạt')
insert into THAMGIADT values ('001','002',1,0, null)	
insert into THAMGIADT values ('001','002',2,2, null)	
insert into THAMGIADT values ('003','002',2,0, null)	
insert into THAMGIADT values ('009','002',3,0.5, null)	
insert into THAMGIADT values ('009','002',4,1.5, null)	
----------------
update KHOA set TRUONGKHOA = '002' where MAKHOA='CNTT'
update KHOA set TRUONGKHOA = '005' where MAKHOA='VL'
update KHOA set TRUONGKHOA = '004' where MAKHOA='SH'
update KHOA set TRUONGKHOA = '007' where MAKHOA='HH'
----------------
update BOMON set TRUONGBM = '002' where MABM=N'HTTT'
update BOMON set TRUONGBM = '001' where MABM=N'MMT'
update BOMON set TRUONGBM = '005' where MABM=N'VLƯD'
update BOMON set TRUONGBM = '004' where MABM=N'VS'
update BOMON set TRUONGBM = '007' where MABM=N'HPT'
----------------
insert into NGUOITHAN values ('001', N'Hùng', '1/14/1990', N'Nam')
insert into NGUOITHAN values ('001', N'Thủy', '12/8/1994', N'Nữ')
insert into NGUOITHAN values ('003', N'Thu', '9/3/1998', N'Nữ')
insert into NGUOITHAN values ('003', N'Hà', '9/3/1998', N'Nữ')
insert into NGUOITHAN values ('008', N'Nam', '5/6/1991', N'Nam')
insert into NGUOITHAN values ('010', N'Nguyệt', '1/14/2006', N'Nữ')
insert into NGUOITHAN values ('007', N'Vy', '2/14/2000', N'Nữ')
insert into NGUOITHAN values ('007', N'Mai', '3/26/2003', N'Nữ')
insert into NGUOITHAN values ('009', N'An', '8/19/1996', N'Nam')

select * FROM dbo.BOMON
select * FROM dbo.CHUDE
select * FROM dbo.CONGVIEC
select * FROM dbo.DETAI
select * FROM dbo.GIAOVIEN
select * FROM dbo.GV_DT
select * FROM dbo.KHOA
select * FROM dbo.NGUOITHAN
select * FROM dbo.THAMGIADT
-------------------------------
--------Truy vấn sử dụng-------
----hàm kết hợp và gom nhóm----
-------------------------------
-- các toán tử IN, NOT IN, ALL,ANY,SOME
-- các toán tử EXIST, NOT EXIST

-- CHO BIẾT GV tham gia nhiều công việc nhất
SELECT DT.MAGV, COUNT(*) 
FROM THAMGIADT DT
GROUP BY DT.MAGV
having COUNT(*) >= ALL(SELECT COUNT(*)
						FROM THAMGIADT TGDT
						GROUP BY TGDT.MAGV)

-- Cho biết GV tham gia nhiều công việc nhất trong bộ môn của GV đó
SELECT TGDT.MAGV, COUNT(*) as N'SL Công việc'
FROM THAMGIADT TGDT JOIN GIAOVIEN GV 
ON TGDT.MAGV = GV.MAGV
GROUP BY TGDT.MAGV, GV.MABM
having COUNT(*) >= ALL(SELECT COUNT(*)
						FROM THAMGIADT TGDT2 JOIN GIAOVIEN GV2 
						ON TGDT2.MAGV = GV2.MAGV
						WHERE GV2.MABM = GV.MABM
						GROUP BY TGDT2.MAGV
						--HAVING GV2.MABM = GV.MABM
						)

-- câu 35: mức lương cao nhất của các giáo viên

SELECT MAX(GV.LUONG) AS 'Mức lương cao nhất của các giáo viên'
FROM GIAOVIEN GV

-- câu 37: lương cao nhất trong bộ môn HTTT

SELECT DISTINCT GV.LUONG as 'Lương cao nhất trong bộ môn HTTT'
FROM GIAOVIEN GV
where GV.LUONG = (SELECT MAX(GV2.LUONG)
					FROM GIAOVIEN GV2)
-- câu 39: tên GV nhỏ tuổi nhất khoa Công nghệ thông tin

SELECT GV.HOTEN AS 'Tên GV nhỏ tuổi nhất khoa Công nghệ thông tin'
FROM GIAOVIEN GV JOIN BOMON BM
ON GV.MABM = BM.MABM -- tạo LK GiaoVien với BOMON
JOIN KHOA K
ON BM.MAKHOA = K.MAKHOA -- tạo LK BOMON với KHOA 
WHERE GV.NGSINH >= ALL(SELECT NGSINH
						FROM BOMON BM2 JOIN KHOA K2
						ON BM2.MAKHOA = K2.MAKHOA -- tạo LK BOMON2 với KHOA2
						JOIN GIAOVIEN GV2
						ON GV2.MABM = BM2.MABM -- tạo LK GiaoVien2 với BOMON2
						WHERE K2.TENKHOA = N'Công nghệ thông tin')
AND K.TENKHOA = N'Công nghệ thông tin'


-- câu 41: những GV có lương lớn nhất trong Bộ môn của họ

SELECT GV1.MAGV as N'Mã giáo viên có lương lớn nhất trong Bộ môn của họ', GV1.MABM as N'Mã BM', GV1.HOTEN as N'Họ và tên', GV1.LUONG as N'Lương'
FROM GIAOVIEN GV1
GROUP BY GV1.MAGV, GV1.MABM, GV1.HOTEN, GV1.LUONG
HAVING GV1.LUONG >= ALL(SELECT GV2.LUONG
						FROM GIAOVIEN GV2
						GROUP BY GV2.LUONG,GV2.MABM -- có sử dụng Luong và Mã BM để so sánh 2 bảng GIAOVIEN với nhau
						HAVING GV1.MABM = GV2.MABM) -- tạo LK GiaoVien1 với GiaoVien2

-- câu 43: những đề tài mà giáo viên Nguyễn Hoài An chưa tham gia
		-- Xuất ra tên đề tài, tên người chủ nhiệm đề tài


SELECT DISTINCT DT.TENDT, GV.HOTEN
FROM DETAI DT JOIN GIAOVIEN GV ON DT.GVCNDT = GV.MAGV
where DT.TENDT NOT IN (SELECT distinct DT2.TENDT
						FROM THAMGIADT TGDT2 join GIAOVIEN GV2
						ON TGDT2.MAGV = GV2.MAGV
						JOIN DETAI DT2
						ON DT2.MADT = TGDT2.MADT
						WHERE GV2.HOTEN = N'Nguyễn Hoài An'
						)

/*SELECT DISTINCT DT.TENDT, GV.HOTEN
FROM DETAI DT JOIN GIAOVIEN GV ON DT.GVCNDT = GV.MAGV
EXCEPT
SELECT DISTINCT DT2.TENDT, GV2.HOTEN
FROM THAMGIADT TGDT2 join GIAOVIEN GV2
ON TGDT2.MAGV = GV2.MAGV
JOIN DETAI DT2
ON DT2.MADT = TGDT2.MADT
WHERE GV2.HOTEN = N'Nguyễn Hoài An'*/

-- câu 45: những GV ko tham gia bất kì đề tài nào
SELECT*
FROM GIAOVIEN GV
WHERE GV.MAGV NOT IN (SELECT TGDT.MAGV
						FROM THAMGIADT TGDT)

-- câu 47: Những trưởng BM 
--		tham gia tối thiểu 1 đề tài

SELECT BM.TRUONGBM AS N'Mã trưởng Bộ môn tham gia tối thiểu 1 đề tài', COUNT(*) AS 'SL DETAI'
FROM THAMGIADT TGDT JOIN BOMON BM
ON TGDT.MAGV = BM.TRUONGBM
GROUP BY BM.TRUONGBM
HAVING COUNT(TGDT.MADT) >= 1

-- câu 49: tìm những GV có lương > lương của ít nhất 1 GV thuộc Bộ môn Công nghệ phần mềm

SELECT GV2.MAGV as N'những GV có lương lớn hơn lương của ít nhất 1 GV thuộc Bộ môn Công nghệ phần mềm'
FROM GIAOVIEN GV2
WHERE EXISTS(SELECT DISTINCT GV.LUONG
			FROM KHOA JOIN BOMON BM
			ON KHOA.MAKHOA = BM.MAKHOA
			JOIN GIAOVIEN GV
			ON GV.MABM = BM.MABM
			WHERE BM.TENBM = N'Công nghệ phần mềm'--N'Hệ thống thông tin' 
			AND GV2.LUONG > GV.LUONG
)


-- câu 51: tên khoa có đông GV nhất
SELECT KHOA.MAKHOA, KHOA.TENKHOA as 'Tên khoa có đông GV nhất'--GV.MABM
FROM KHOA JOIN BOMON BM
ON KHOA.MAKHOA = BM.MAKHOA -- tạo LK KHOA với BOMON
JOIN GIAOVIEN GV
ON GV.MABM = BM.MABM -- tạo LK GIAOVIEN với BOMON
GROUP BY KHOA.MAKHOA, KHOA.TENKHOA--GV.MABM
HAVING COUNT(*) >= ALL( SELECT COUNT(*)
					FROM KHOA K2 JOIN BOMON BM2
					ON K2.MAKHOA = BM2.MAKHOA -- tạo LK KHOA2 với BOMON2
					JOIN GIAOVIEN GV2
					ON GV2.MABM = BM2.MABM -- tạo LK GIAOVIEN2 với BOMON2
					GROUP BY K2.MAKHOA, K2.TENKHOA--GV2.MABM)
					)

-- câu 53: mã BM có nhiều GV nhất
SELECT GV.MABM AS N'mã BM có nhiều GV nhất'
FROM GIAOVIEN GV
GROUP BY GV.MABM
HAVING COUNT(*) >= ALL( SELECT COUNT(*)
					FROM GIAOVIEN GV2
					GROUP BY GV2.MABM
					)

-- câu 55: tên GV 
--		tham gia nhiều đề tài nhất
--		của bộ môn HTTT

SELECT GV.HOTEN AS N'Họ và tên GV tham gia nhiều đề tài nhất của bộ môn HTTT', COUNT(TGDT.MAGV) AS N'Số lượng đề tài'
FROM GIAOVIEN GV JOIN THAMGIADT TGDT
ON TGDT.MAGV = GV.MAGV
AND GV.MABM = 'HTTT'
GROUP BY GV.HOTEN
HAVING COUNT(TGDT.MAGV) >= ALL (SELECT COUNT(TGDT2.MAGV)
								FROM THAMGIADT TGDT2
								GROUP BY TGDT2.MAGV
								)

-- câu 57: tên trưởng bộ môn
--		mà chủ nhiệm nhiều đề tài nhất

SELECT DISTINCT GV.HOTEN as N'Tên trưởng bộ môn', COUNT(DT.MADT) as N'Số lượng đề tài chủ nhiệm nhiều nhất'
FROM GIAOVIEN GV, BOMON BM, DETAI DT
WHERE BM.TRUONGBM = GV.MAGV -- là trưởng bộ môn
AND DT.GVCNDT = GV.MAGV -- là GV chủ nhiệm đề tài
GROUP BY GV.HOTEN
HAVING COUNT(DT.MADT) >= ALL (SELECT COUNT(DT2.MADT)
								FROM GIAOVIEN GV2, DETAI DT2
								WHERE GV2.MAGV = DT2.GVCNDT
								GROUP BY GV2.MAGV
								)

-------------------------------
--------Bài tập về nhà-------
----hàm kết hợp và gom nhóm----
-------------------------------

-- câu 36: các giáo viên có mức lương cao nhất

SELECT GV.MAGV AS 'Những giáo viên có mức lương cao nhất'
FROM GIAOVIEN GV
where GV.LUONG = (SELECT MAX(GV2.LUONG)
					FROM GIAOVIEN GV2)
-- câu 38: tên GV lớn tuổi nhất của Bộ môn Hệ thống thông tin

SELECT GV.HOTEN AS 'Tên GV lớn tuổi nhất của Bộ môn Hệ thống thông tin'
FROM GIAOVIEN GV JOIN BOMON BM
ON GV.MABM = BM.MABM -- tạo LK GiaoVien với BOMON
WHERE GV.NGSINH <= ALL(SELECT NGSINH
						FROM BOMON BM2 JOIN GIAOVIEN GV2
						ON GV2.MABM = BM2.MABM -- tạo LK GiaoVien2 với BOMON2
						WHERE BM2.TENBM = N'Hệ thống thông tin')
AND BM.TENBM = N'Hệ thống thông tin'

-- câu 40: tên GV và tên Khoa của GV có lương cao nhất

SELECT GV.HOTEN as N'Họ và tên giáo viên', K.TENKHOA as N'Tên Khoa của GV có lương cao nhất'--, GV.LUONG
FROM GIAOVIEN GV, KHOA K JOIN BOMON BM ON K.MAKHOA = BM.MAKHOA -- tạo LK Khoa với BOMON
WHERE GV.MABM = BM.MABM -- tạo LK GiaoVien với BOMON
AND GV.LUONG >= ALL(SELECT GV2.LUONG
						FROM GIAOVIEN GV2
						)

-- câu 42: tên những đề tài
--		mà GV Nguyễn Hoài An chưa tham gia

SELECT DISTINCT DT.TENDT AS N'Tên những đề tài mà GV Nguyễn Hoài An chưa tham gia'
FROM DETAI DT
where DT.TENDT NOT IN (SELECT distinct DT2.TENDT
						FROM THAMGIADT TGDT2 join GIAOVIEN GV2 
						ON TGDT2.MAGV = GV2.MAGV -- tạo LK THAMGIADT với GIAOVIEN
						JOIN DETAI DT2
						ON DT2.MADT = TGDT2.MADT -- tạo LK DeTai với THAMGIADT
						WHERE GV2.HOTEN = N'Nguyễn Hoài An'
						)
-- Table toàn bộ tên đề tài - Table đề tài mà GV Nguyễn Hoài An tham gia = Kết quả

-- câu 44: tên những GV khoa Công nghệ thông tin
--		mà chưa tham gia đề tài nào

SELECT GV.HOTEN as N'Tên những GV khoa Công nghệ thông tin mà chưa tham gia đề tài nào'
FROM GIAOVIEN GV JOIN BOMON BM
ON GV.MABM = BM.MABM
JOIN KHOA
ON KHOA.MAKHOA = BM.MAKHOA
AND KHOA.TENKHOA = N'Công nghệ thông tin'
WHERE GV.MAGV NOT IN (SELECT TGDT.MAGV
					FROM THAMGIADT TGDT)

-- câu 46: GV có lương > lương của GV "Nguyễn Hoài An"

SELECT* 
FROM GIAOVIEN GV
WHERE GV.LUONG > (SELECT GV2.LUONG
					FROM GIAOVIEN GV2
					WHERE GV2.HOTEN = N'Nguyễn Hoài An'
					)
-- TABLE toàn bộ giáo viên (lương) - Table GV Nguyễn Hoài An (lương) = Kết quả

-- câu 48: những GV trùng tên 
--		và cùng giới tính 
--		với GV khác trong cùng 1 bộ môn

SELECT *
FROM GIAOVIEN GV
WHERE EXISTS (SELECT*
				FROM GIAOVIEN GV2
				WHERE GV.HOTEN = GV2.HOTEN -- trùng tên
				AND GV.PHAI = GV2.PHAI -- cùng giới tính 
				AND GV.MABM = GV2.MABM -- cùng 1 bộ môn
				AND GV.MAGV != GV2.MAGV -- để phân biệt 2 bảng GIAOVIEN với nhau
				)


-- câu 50: những GV có lương > lương của tất cả GV 
--		thuộc bộ môn "Hệ thống thông tin"

SELECT * 
FROM GIAOVIEN GV
WHERE GV.LUONG > ALL(SELECT GV2.LUONG
					FROM GIAOVIEN GV2 JOIN BOMON BM ON BM.MABM = GV2.MABM
					WHERE BM.TENBM = N'Hệ thống thông tin'
					)
-- Table Lương toàn bộ GV > ALL (Table toàn bộ GV thuộc bộ môn "Hệ thống thông tin) = Kết quả

-- câu 52: Cho biết tên GV chủ nhiệm nhiều đề tài nhất

SELECT GV.HOTEN AS N'tên GV chủ nhiệm nhiều đề tài nhất'
FROM GIAOVIEN GV JOIN DETAI DT
ON GV.MAGV = DT.GVCNDT
GROUP BY GV.HOTEN
HAVING COUNT(DT.GVCNDT) >= ALL (SELECT COUNT(DT2.GVCNDT)
								FROM DETAI DT2 JOIN GIAOVIEN GV2 ON GV2.MAGV = DT2.GVCNDT
								GROUP BY GV2.MAGV
								)

-- câu 54: Cho biết tên GV và tên bộ môn của GV tham gia nhiều đề tài nhất

SELECT GV.HOTEN AS N'Tên GV', BM.TENBM AS N'Tên bộ môn của GV tham gia nhiều đề tài nhất'
FROM GIAOVIEN GV JOIN BOMON BM ON GV.MABM = BM.MABM
JOIN THAMGIADT TGDT
ON TGDT.MAGV = GV.MAGV
GROUP BY GV.HOTEN, BM.TENBM
HAVING COUNT(*) >= ALL (SELECT COUNT(*)
						FROM GIAOVIEN GV2 JOIN THAMGIADT TGDT2
						ON TGDT2.MAGV = GV2.MAGV
						GROUP BY TGDT2.MAGV
						)

-- câu 56: Cho biết tên GV và tên bộ môn của GV có nhiều người thân nhất

SELECT GV.HOTEN AS N'Tên GV', BM.TENBM AS N'Tên bộ môn của GV có nhiều người thân nhất'
FROM GIAOVIEN GV JOIN BOMON BM ON GV.MABM = BM.MABM
join NGUOITHAN NT ON NT.MAGV = GV.MAGV
GROUP BY GV.HOTEN, BM.TENBM 
HAVING COUNT(*) >= ALL (SELECT COUNT(*)
						FROM GIAOVIEN GV2 JOIN NGUOITHAN NT2 ON NT2.MAGV = GV2.MAGV
						GROUP BY GV2.HOTEN
						)


--------------------------------
-----Truy vấn lồng nâng cao-----
-------------BTTL#7-------------
SELECT DISTINCT TG1.MAGV
FROM THAMGIADT TG1
WHERE NOT EXISTS (
					(SELECT MADT FROM DETAI)
					EXCEPT
					(SELECT MADT
					FROM THAMGIADT TG2
					WHERE TG2.MAGV = TG1.MAGV
					)
				)
------
-- 9: Tìm tên các giáo viên ‘HTTT’ 
--	mà tham gia tất cả các đề tài thuộc chủ đề 'QLGD'
-- EXCEPT
--Select GV.MAGV, GV.HOTEN
--FROM THAMGIADT TG JOIN GIAOVIEN GV ON GV.MAGV = TG.MAGV
--WHERE NOT EXISTS (Select DT1.MADT
--				  FROM DETAI DT1
--				  EXCEPT
--				  SELECT TG2.MADT
--				  FROM THAMGIADT TG2
--				  WHERE TG2.MAGV = GV.MAGV
--)

--SELECT DT.MADT, DT.TENDT
--FROM DETAI DT
--WHERE NOT EXISTS (SELECT GV1.MAGV
--				  FROM GIAOVIEN GV1
--				  EXCEPT
--				  SELECT TG2.MAGV
--				  FROM THAMGIADT TG2
--				  WHERE TG2.MADT = DT.MADT
--)
--select * FROM CONGVIEC CV

--select GV.MAGV, GV.HOTEN
--FROM GIAOVIEN GV
--WHERE NOT EXISTS (SELECT DISTINCT CV1.MADT, CV1.SOTT
--				  FROM CONGVIEC CV1
--				  EXCEPT
--				  SELECT DISTINCT TG2.MADT, TG2.STT
--				  FROM THAMGIADT TG2
--				  WHERE TG2.MAGV = GV.MAGV
--)

SELECT DISTINCT TG1.MAGV,GV.HOTEN
FROM THAMGIADT TG1,GIAOVIEN GV
WHERE TG1.MAGV = GV.MAGV 
AND GV.MABM = N'HTTT'
AND NOT EXISTS (
				(SELECT MADT FROM DETAI WHERE MACD = N'QLGD')
				EXCEPT
				(SELECT MADT
				FROM THAMGIADT TG2
				WHERE TG2.MAGV=TG1.MAGV )
)
-- NOT EXISTS
SELECT TG1.MAGV,GV.HOTEN 
FROM THAMGIADT TG1, GIAOVIEN GV
WHERE TG1.MAGV = GV.MAGV 
AND GV.MABM= N'HTTT'
AND NOT EXISTS (
				SELECT *
				FROM DETAI DT
				WHERE MACD= N'QLGD' AND NOT EXISTS (
													SELECT * 
													FROM THAMGIADT TG2
													WHERE TG2.MADT=DT.MADT AND TG2.MAGV=TG1.MAGV
													)
				)

-- COUNT   
SELECT TG1.MAGV , GV.HOTEN 
FROM THAMGIADT TG1 , GIAOVIEN GV
WHERE TG1.MAGV = GV.MAGV 
AND GV.MABM = N'HTTT'  
AND TG1.MADT IN (SELECT MADT FROM DETAI WHERE MACD = N'QLGD') 
GROUP BY TG1.MAGV , GV.HOTEN
HAVING COUNT(DISTINCT TG1.MADT) = 
								(
								SELECT COUNT(MADT)
								FROM DETAI 
								WHERE MACD= N'QLGD'
								)
-- Q58. Cho biết tên giáo viên nào
--	mà tham gia đề tài đủ tất cả các chủ đề.

-- (...) EXCEPT (...)
SELECT DISTINCT GV.HOTEN
FROM THAMGIADT TG1 join GIAOVIEN GV ON GV.MAGV = TG1.MAGV
WHERE NOT EXISTS (
					(SELECT CD.MACD FROM CHUDE CD)
					EXCEPT
					(SELECT CD2.MACD

					FROM CHUDE CD2 JOIN DETAI DT ON DT.MACD = CD2.MACD
					JOIN THAMGIADT TG2 ON TG2.MADT = DT.MADT
					JOIN GIAOVIEN GV2 ON GV2.MAGV = TG2.MAGV
					WHERE TG2.MAGV = TG1.MAGV
					)
				)

-- WHERE NOT EXSISTS (...) 
-- => tạo 1 liên kết từ bảng dưới với bảng trên, thường cho 2 bảng giống nhau sẽ dễ hơn
-- => nếu SELECT có 2 thuộc tính thì tạo 2 liên kết như trên
SELECT DISTINCT GV.HOTEN
FROM THAMGIADT TG1 join GIAOVIEN GV ON GV.MAGV = TG1.MAGV
WHERE NOT EXISTS (SELECT CD.MACD FROM CHUDE CD
					WHERE NOT EXISTS
					(SELECT CD2.MACD
					FROM CHUDE CD2 JOIN DETAI DT ON DT.MACD = CD2.MACD
					JOIN THAMGIADT TG2 ON TG2.MADT = DT.MADT
					JOIN GIAOVIEN GV2 ON GV2.MAGV = TG2.MAGV
					WHERE TG2.MAGV = TG1.MAGV AND CD.MACD = CD2.MACD
					)
				)

-- WHERE ... NOT IN (...)
-- => lấy giá trị sau Select làm thành phần ... NOT IN
SELECT DISTINCT GV.HOTEN
FROM THAMGIADT TG1 JOIN GIAOVIEN GV ON GV.MAGV = TG1.MAGV
WHERE NOT EXISTS (
					SELECT CD.MACD FROM CHUDE CD
					WHERE CD.MACD NOT IN
					(
					SELECT CD2.MACD
					FROM CHUDE CD2 JOIN DETAI DT ON DT.MACD = CD2.MACD
					JOIN THAMGIADT TG2 ON TG2.MADT = DT.MADT
					JOIN GIAOVIEN GV2 ON GV2.MAGV = TG2.MAGV
					WHERE TG2.MAGV = TG1.MAGV
					)
				)

-- câu 60:  Cho biết tên đề tài 
--	có tất cả giảng viên bộ môn “Hệ thống thông tin”
--	tham gia

-- EXCEPT
SELECT DT.TENDT AS N'Tên đề tài có tất cả giảng viên bộ môn “Hệ thống thông tin tham gia'
FROM DETAI DT
WHERE NOT EXISTS (
					SELECT GV.MAGV
					FROM GIAOVIEN GV JOIN BOMON BM ON BM.MABM = GV.MABM
					WHERE BM.TENBM = N'Hệ thống thông tin'
					EXCEPT
					SELECT GV2.MAGV
					FROM GIAOVIEN GV2 JOIN THAMGIADT TG2 ON TG2.MAGV = GV2.MAGV
					JOIN BOMON BM2 ON BM2.MABM = GV2.MABM
					WHERE TG2.MADT = DT.MADT
)

-- WHERE NOT EXSISTS (...) 
-- => tạo 1 liên kết từ bảng dưới với bảng trên, thường cho 2 bảng giống nhau sẽ dễ hơn
-- => nếu SELECT có 2 thuộc tính thì tạo 2 liên kết như trên
SELECT DT.TENDT AS N'Tên đề tài có tất cả giảng viên bộ môn “Hệ thống thông tin tham gia'
FROM DETAI DT
WHERE NOT EXISTS (
					SELECT GV.MAGV
					FROM GIAOVIEN GV JOIN BOMON BM ON BM.MABM = GV.MABM AND BM.TENBM = N'Hệ thống thông tin' 
					WHERE NOT EXISTS
					(
					SELECT GV2.MAGV
					FROM GIAOVIEN GV2 JOIN THAMGIADT TG2 ON TG2.MAGV = GV2.MAGV
					JOIN BOMON BM2 ON BM2.MABM = GV2.MABM
					WHERE TG2.MADT = DT.MADT
					AND GV.MAGV = GV2.MAGV -- LIEN KET CHO 2 BANG VOI NHAU
					)
)

-- WHERE ... NOT IN (...)
-- => lấy giá trị sau Select làm thành phần ... NOT IN
SELECT DT.TENDT AS N'Tên đề tài có tất cả giảng viên bộ môn “Hệ thống thông tin tham gia'
FROM DETAI DT
WHERE NOT EXISTS (
					SELECT GV.MAGV
					FROM GIAOVIEN GV JOIN BOMON BM ON BM.MABM = GV.MABM
					AND BM.TENBM = N'Hệ thống thông tin'
					WHERE GV.MAGV NOT IN (
					SELECT GV2.MAGV
					FROM GIAOVIEN GV2 JOIN THAMGIADT TG2 ON TG2.MAGV = GV2.MAGV
					JOIN BOMON BM2 ON BM2.MABM = GV2.MABM
					WHERE TG2.MADT = DT.MADT
					)
)


-- câu 62:Cho biết tên giáo viên
--	nào tham gia 
--	tất cả các đề tài 
--	mà giáo viên Trần Trà Hương đã tham gia.

SELECT GV.HOTEN
FROM GIAOVIEN GV
WHERE NOT EXISTS (SELECT DISTINCT TG.MADT
				FROM THAMGIADT TG JOIN GIAOVIEN GV1 ON GV1.MAGV = TG.MAGV
				WHERE GV1.HOTEN = N'Trần Trà Hương'
				EXCEPT
				SELECT DISTINCT TG2.MADT
				FROM THAMGIADT TG2
				WHERE TG2.MAGV = GV.MAGV
				)
AND GV.HOTEN != N'Trần Trà Hương'

-- WHERE NOT EXSISTS (...) 
-- => tạo 1 liên kết từ bảng dưới với bảng trên, thường cho 2 bảng giống nhau sẽ dễ hơn
-- => nếu SELECT có 2 thuộc tính thì tạo 2 liên kết như trên
SELECT GV.HOTEN
FROM GIAOVIEN GV
WHERE NOT EXISTS (SELECT DISTINCT TG.MADT
				FROM THAMGIADT TG JOIN GIAOVIEN GV1 ON GV1.MAGV = TG.MAGV
				WHERE GV1.HOTEN = N'Trần Trà Hương'
				AND NOT EXISTS (SELECT DISTINCT TG2.MADT
								FROM THAMGIADT TG2
								WHERE TG2.MAGV = GV.MAGV
								AND TG.MADT = TG2.MADT
								)
				)
AND GV.HOTEN != N'Trần Trà Hương'


-- WHERE ... NOT IN (...)
-- => lấy giá trị sau Select làm thành phần ... NOT IN
SELECT GV.HOTEN
FROM GIAOVIEN GV
WHERE NOT EXISTS (SELECT DISTINCT TG1.MADT
				FROM THAMGIADT TG1 JOIN GIAOVIEN GV1 ON GV1.MAGV = TG1.MAGV
				WHERE GV1.HOTEN = N'Trần Trà Hương'
				AND TG1.MADT NOT IN (SELECT DISTINCT TG2.MADT
									FROM THAMGIADT TG2
									WHERE TG2.MAGV = GV.MAGV
									)
				)
AND GV.HOTEN != N'Trần Trà Hương'

-- câu 64: Cho biết tên giáo viên
--	nào mà tham gia
--	tất cả các công việc
--	của đề tài 006.

-- EXCEPT
SELECT GV.HOTEN
FROM GIAOVIEN GV
WHERE NOT EXISTS (SELECT CV.SOTT, CV.MADT
					FROM CONGVIEC CV
					WHERE CV.MADT = '006'
					EXCEPT
					SELECT TG.STT, CV2.MADT
					FROM CONGVIEC CV2 JOIN THAMGIADT TG ON TG.MADT = CV2.MADT
					WHERE TG.MAGV = GV.MAGV
)
-- WHERE NOT EXSISTS (...) 
-- => tạo 1 liên kết từ bảng dưới với bảng trên, thường cho 2 bảng giống nhau sẽ dễ hơn
-- => nếu SELECT có 2 thuộc tính thì tạo 2 liên kết như trên
SELECT GV.HOTEN
FROM GIAOVIEN GV
WHERE NOT EXISTS (SELECT CV.SOTT, CV.MADT
					FROM CONGVIEC CV
					WHERE CV.MADT = '006'
					AND NOT EXISTS (SELECT TG.STT, CV2.MADT
									FROM CONGVIEC CV2 JOIN THAMGIADT TG ON TG.MADT = CV2.MADT
									WHERE TG.MAGV = GV.MAGV
									AND CV.SOTT = TG.STT -- LIEN KET 1
									AND CV.MADT = CV2.MADT -- LIEN KET 1
									)
)

-- WHERE ... NOT IN (...)
-- => lấy giá trị sau Select làm thành phần ... NOT IN
SELECT GV.HOTEN
FROM GIAOVIEN GV
WHERE NOT EXISTS (SELECT CV.SOTT
					FROM CONGVIEC CV
					WHERE CV.MADT = '006'
					AND CV.SOTT NOT IN (SELECT TG.STT
										FROM CONGVIEC CV2 JOIN THAMGIADT TG ON TG.MADT = CV2.MADT
										WHERE TG.MAGV = GV.MAGV
										AND CV2.MADT = CV.MADT -- điều kiện thêm
					)
)

-- câu 66:  Cho biết tên giáo viên
--	nào đã tham gia
--	tất cả các đề tài
--	của do Trần Trà Hương
--	làm chủ nhiệm

-- EXCEPT
SELECT GV.HOTEN
FROM GIAOVIEN GV
WHERE NOT EXISTS (SELECT DT1.MADT
					FROM DETAI DT1 JOIN GIAOVIEN GV1 ON GV1.MAGV = DT1.GVCNDT
					WHERE GV1.HOTEN = N'Trần Trà Hương'
					EXCEPT
					SELECT TG2.MADT
					FROM THAMGIADT TG2 
					WHERE TG2.MAGV = GV.MAGV
)

-- WHERE NOT EXSISTS (...) 
-- => tạo 1 liên kết từ bảng dưới với bảng trên, thường cho 2 bảng giống nhau sẽ dễ hơn
-- => nếu SELECT có 2 thuộc tính thì tạo 2 liên kết như trên
SELECT GV.HOTEN
FROM GIAOVIEN GV
WHERE NOT EXISTS (SELECT DT1.MADT
					FROM DETAI DT1 JOIN GIAOVIEN GV1 ON GV1.MAGV = DT1.GVCNDT
					WHERE GV1.HOTEN = N'Trần Trà Hương'
					AND NOT EXISTS (SELECT TG2.MADT
									FROM THAMGIADT TG2 
									WHERE TG2.MAGV = GV.MAGV
									AND DT1.MADT = TG2.MADT
									)
)

-- WHERE ... NOT IN (...)
-- => lấy giá trị sau Select làm thành phần ... NOT IN
SELECT GV.HOTEN
FROM GIAOVIEN GV
WHERE NOT EXISTS (SELECT DT1.MADT
					FROM DETAI DT1 JOIN GIAOVIEN GV1 ON GV1.MAGV = DT1.GVCNDT
					WHERE GV1.HOTEN = N'Trần Trà Hương'
					AND DT1.MADT NOT IN (SELECT TG2.MADT
										FROM THAMGIADT TG2 
										WHERE TG2.MAGV = GV.MAGV
										)
)

-- câu 68: Cho biết tên giáo viên nào
--	mà tham gia
--	tất cả các công việc
--	của đề tài Nghiên cứu tế bào gốc

-- EXCEPT
SELECT GV.HOTEN
FROM GIAOVIEN GV
WHERE NOT EXISTS (SELECT CV.MADT, CV.SOTT
					FROM CONGVIEC CV JOIN DETAI DT ON DT.MADT = CV.MADT
					WHERE DT.TENDT = N'Nghiên cứu tế bào gốc'
					EXCEPT
					SELECT CV2.MADT, TG2.STT
					FROM CONGVIEC CV2 JOIN THAMGIADT TG2 ON TG2.MADT = CV2.MADT
					WHERE TG2.MAGV = GV.MAGV
)

-- WHERE NOT EXSISTS (...) 
-- => tạo 1 liên kết từ bảng dưới với bảng trên, thường cho 2 bảng giống nhau sẽ dễ hơn
-- => nếu SELECT có 2 thuộc tính thì tạo 2 liên kết như trên
SELECT GV.HOTEN
FROM GIAOVIEN GV
WHERE NOT EXISTS (SELECT CV.MADT, CV.SOTT
					FROM CONGVIEC CV JOIN DETAI DT ON DT.MADT = CV.MADT
					WHERE DT.TENDT = N'Nghiên cứu tế bào gốc'
					AND NOT EXISTS (SELECT CV2.MADT, TG2.STT
									FROM CONGVIEC CV2 JOIN THAMGIADT TG2 ON TG2.MADT = CV2.MADT
									WHERE TG2.MAGV = GV.MAGV
									AND CV.MADT = CV2.MADT
									AND CV.SOTT = TG2.STT
									)
)


-- WHERE ... NOT IN (...)
-- => lấy giá trị sau Select làm thành phần ... NOT IN
SELECT GV.HOTEN
FROM GIAOVIEN GV
WHERE NOT EXISTS (SELECT CV.MADT 
					FROM CONGVIEC CV JOIN DETAI DT ON DT.MADT = CV.MADT
					WHERE DT.TENDT = N'Nghiên cứu tế bào gốc'
					AND CV.MADT NOT IN (SELECT CV2.MADT
										FROM CONGVIEC CV2 JOIN THAMGIADT TG2 ON TG2.MADT = CV2.MADT
										WHERE TG2.MAGV = GV.MAGV
										AND CV.SOTT = TG2.STT -- điều kiện thêm
										)
)

-- câu 70:  Cho biết tên đề tài nào
--	mà được tất cả các giáo viên
--	của khoa Sinh Học
--	tham gia.

-- EXCEPT
SELECT DT.TENDT
FROM DETAI DT
WHERE NOT EXISTS (SELECT GV1.MAGV
					FROM GIAOVIEN GV1 JOIN BOMON BM1 ON BM1.MABM = GV1.MABM
					JOIN KHOA K1 ON K1.MAKHOA = BM1.MAKHOA
					WHERE K1.TENKHOA = N'Sinh học'
					EXCEPT
					SELECT TG2.MAGV
					FROM THAMGIADT TG2
					WHERE TG2.MADT = DT.MADT
)

-- WHERE NOT EXSISTS (...) 
-- => tạo 1 liên kết từ bảng dưới với bảng trên, thường cho 2 bảng giống nhau sẽ dễ hơn
-- => nếu SELECT có 2 thuộc tính thì tạo 2 liên kết như trên
SELECT DT.TENDT
FROM DETAI DT
WHERE NOT EXISTS (SELECT GV1.MAGV
					FROM GIAOVIEN GV1 JOIN BOMON BM1 ON BM1.MABM = GV1.MABM
					JOIN KHOA K1 ON K1.MAKHOA = BM1.MAKHOA
					WHERE K1.TENKHOA = N'Sinh học'
					AND NOT EXISTS (SELECT TG2.MAGV
									FROM THAMGIADT TG2
									WHERE TG2.MADT = DT.MADT
									AND GV1.MAGV = TG2.MAGV
									)
)

-- WHERE ... NOT IN (...)
-- => lấy giá trị sau Select làm thành phần ... NOT IN
SELECT DT.TENDT
FROM DETAI DT
WHERE NOT EXISTS (SELECT GV1.MAGV
					FROM GIAOVIEN GV1 JOIN BOMON BM1 ON BM1.MABM = GV1.MABM
					JOIN KHOA K1 ON K1.MAKHOA = BM1.MAKHOA
					WHERE K1.TENKHOA = N'Sinh học'
					AND GV1.MAGV NOT IN (SELECT TG2.MAGV
										FROM THAMGIADT TG2
										WHERE TG2.MADT = DT.MADT
										)
)

-- câu 72: Cho biết mã số
--	, họ tên
--	, tên bộ môn
--	và tên người quản lý chuyên môn
--	của giáo viên
--	tham gia tất cả các đề tài
--	thuộc chủ đề “Nghiên cứu phát triển”.

-- CACH 2
-- EXCEPT
SELECT GV.MAGV, GV.HOTEN, BM.TENBM, (SELECT GV1.HOTEN
										FROM GIAOVIEN GV1
										WHERE GV1.GVQLCM = GV.MAGV) as N'Tên người quản lý chuyên môn'
FROM GIAOVIEN GV JOIN BOMON BM ON BM.MABM = GV.MABM
WHERE NOT EXISTS (SELECT DT2.MADT
					FROM DETAI DT2 JOIN CHUDE CD2 ON CD2.MACD = DT2.MACD
					WHERE CD2.TENCD = N'Nghiên cứu phát triển'
					EXCEPT
					SELECT TG3.MADT
					FROM THAMGIADT TG3
					WHERE TG3.MAGV = GV.MAGV
)

-- WHERE NOT EXISTS (...) 
-- => tạo 1 liên kết từ bảng dưới với bảng trên, thường cho 2 bảng giống nhau sẽ dễ hơn
-- => nếu SELECT có 2 thuộc tính thì tạo 2 liên kết như trên
SELECT GV.MAGV, GV.HOTEN, BM.TENBM, (SELECT GV1.HOTEN
										FROM GIAOVIEN GV1
										WHERE GV1.GVQLCM = GV.MAGV) as N'Tên người quản lý chuyên môn'
FROM GIAOVIEN GV JOIN BOMON BM ON BM.MABM = GV.MABM
WHERE NOT EXISTS (SELECT DT2.MADT
					FROM DETAI DT2 JOIN CHUDE CD2 ON CD2.MACD = DT2.MACD
					WHERE CD2.TENCD = N'Nghiên cứu phát triển'
					AND NOT EXISTS (SELECT TG3.MADT
									FROM THAMGIADT TG3
									WHERE TG3.MAGV = GV.MAGV
									AND DT2.MADT = TG3.MADT
									)
)

-- WHERE ... NOT IN (...)
-- => lấy giá trị sau Select làm thành phần ... NOT IN
SELECT GV.MAGV, GV.HOTEN, BM.TENBM, (SELECT GV1.HOTEN
										FROM GIAOVIEN GV1
										WHERE GV1.GVQLCM = GV.MAGV) as N'Tên người quản lý chuyên môn'
FROM GIAOVIEN GV JOIN BOMON BM ON BM.MABM = GV.MABM
WHERE NOT EXISTS (SELECT DT2.MADT
					FROM DETAI DT2 JOIN CHUDE CD2 ON CD2.MACD = DT2.MACD
					WHERE CD2.TENCD = N'Nghiên cứu phát triển'
					AND DT2.MADT NOT IN (SELECT TG3.MADT
									FROM THAMGIADT TG3
									WHERE TG3.MAGV = GV.MAGV
									)
)


--------------------------------
-----Truy vấn lồng nâng cao-----
-------------BTVN#7-------------

-- câu 59:Cho biết tên đề tài nào
--	mà được tất cả các giáo viên
--	của bộ môn HTTT
--	tham gia.

-- EXCEPT
SELECT DT.TENDT
FROM DETAI DT
WHERE NOT EXISTS (SELECT TG1.MAGV
					FROM THAMGIADT TG1 JOIN GIAOVIEN GV1 ON TG1.MAGV = GV1.MAGV
					WHERE GV1.MABM = N'HTTT'
					EXCEPT
					SELECT TG2.MAGV
					FROM THAMGIADT TG2
					WHERE TG2.MADT = DT.MADT
)

-- WHERE NOT EXISTS (...) 
-- => tạo 1 liên kết từ bảng dưới với bảng trên, thường cho 2 bảng giống nhau sẽ dễ hơn
-- => nếu SELECT có 2 thuộc tính thì tạo 2 liên kết như trên
SELECT DT.TENDT
FROM DETAI DT
WHERE NOT EXISTS (SELECT TG1.MAGV
					FROM THAMGIADT TG1 JOIN GIAOVIEN GV1 ON TG1.MAGV = GV1.MAGV
					WHERE GV1.MABM = N'HTTT'
					AND NOT EXISTS (SELECT TG2.MAGV
									FROM THAMGIADT TG2
									WHERE TG2.MADT = DT.MADT
									AND TG1.MAGV = TG2.MAGV
									)
)

-- WHERE ... NOT IN (...)
-- => lấy giá trị sau Select làm thành phần ... NOT IN
SELECT DT.TENDT
FROM DETAI DT
WHERE NOT EXISTS (SELECT TG1.MAGV
					FROM THAMGIADT TG1 JOIN GIAOVIEN GV1 ON TG1.MAGV = GV1.MAGV
					WHERE GV1.MABM = N'HTTT'
					AND TG1.MAGV NOT IN (SELECT TG2.MAGV
										 FROM THAMGIADT TG2
										 WHERE TG2.MADT = DT.MADT
										 )
)

-- câu 61: Cho biết giáo viên nào
--	đã tham gia
--	tất cả các đề tài
--	có mã chủ đề là QLGD.

-- EXCEPT
SELECT GV.MAGV
FROM GIAOVIEN GV
WHERE NOT EXISTS (SELECT DT1.MADT
					FROM DETAI DT1
					WHERE DT1.MACD = N'QLGD'
					EXCEPT
					SELECT DISTINCT TG2.MADT
					FROM THAMGIADT TG2
					WHERE TG2.MAGV = GV.MAGV
)

-- WHERE NOT EXISTS (...) 
-- => tạo 1 liên kết từ bảng dưới với bảng trên, thường cho 2 bảng giống nhau sẽ dễ hơn
-- => nếu SELECT có 2 thuộc tính thì tạo 2 liên kết như trên
SELECT GV.MAGV
FROM GIAOVIEN GV
WHERE NOT EXISTS (SELECT DT1.MADT
					FROM DETAI DT1
					WHERE DT1.MACD = N'QLGD'
					AND NOT EXISTS (SELECT DISTINCT TG2.MADT
									FROM THAMGIADT TG2
									WHERE TG2.MAGV = GV.MAGV
									AND DT1.MADT = TG2.MADT
									)
)


-- WHERE ... NOT IN (...)
-- => lấy giá trị sau Select làm thành phần ... NOT IN
SELECT GV.MAGV
FROM GIAOVIEN GV
WHERE NOT EXISTS (SELECT DT1.MADT
					FROM DETAI DT1
					WHERE DT1.MACD = N'QLGD'
					AND DT1.MADT NOT IN (SELECT DISTINCT TG2.MADT
										 FROM THAMGIADT TG2
										 WHERE TG2.MAGV = GV.MAGV
										 )
)

-- câu 63:Cho biết tên đề tài nào
--	mà được tất cả các giáo viên
--	của bộ môn Hóa Hữu Cơ
--	tham gia.

-- EXCEPT
SELECT DT.TENDT
FROM DETAI DT
WHERE NOT EXISTS (SELECT DISTINCT TG1.MAGV
				  FROM THAMGIADT TG1 JOIN GIAOVIEN GV1 ON TG1.MAGV = GV1.MAGV
				  JOIN BOMON BM1 ON BM1.MABM = GV1.MABM
				  WHERE BM1.TENBM = N'Hóa hữu cơ'
				  EXCEPT
				  SELECT DISTINCT TG2.MAGV
				  FROM THAMGIADT TG2
				  WHERE TG2.MADT = DT.MADT
)

-- WHERE NOT EXISTS (...) 
-- => tạo 1 liên kết từ bảng dưới với bảng trên, thường cho 2 bảng giống nhau sẽ dễ hơn
-- => nếu SELECT có 2 thuộc tính thì tạo 2 liên kết như trên
SELECT DT.TENDT
FROM DETAI DT
WHERE NOT EXISTS (SELECT DISTINCT TG1.MAGV
				  FROM THAMGIADT TG1 JOIN GIAOVIEN GV1 ON TG1.MAGV = GV1.MAGV
				  JOIN BOMON BM1 ON BM1.MABM = GV1.MABM
				  WHERE BM1.TENBM = N'Hóa hữu cơ'
				  AND NOT EXISTS (SELECT DISTINCT TG2.MAGV
								  FROM THAMGIADT TG2
								  WHERE TG2.MADT = DT.MADT
								  AND TG1.MAGV = TG2.MAGV
								  )
)

-- WHERE ... NOT IN (...)
-- => lấy giá trị sau Select làm thành phần ... NOT IN
SELECT DT.TENDT
FROM DETAI DT
WHERE NOT EXISTS (SELECT DISTINCT TG1.MAGV
				  FROM THAMGIADT TG1 JOIN GIAOVIEN GV1 ON TG1.MAGV = GV1.MAGV
				  JOIN BOMON BM1 ON BM1.MABM = GV1.MABM
				  WHERE BM1.TENBM = N'Hóa hữu cơ'
				  AND TG1.MAGV NOT IN (SELECT DISTINCT TG2.MAGV
									   FROM THAMGIADT TG2
									   WHERE TG2.MADT = DT.MADT
									   )
)

-- Q65. Cho biết giáo viên nào
--	đã tham gia tất cả các đề tài
--	của chủ đề Ứng dụng công nghệ.

-- EXCEPT
SELECT * 
FROM GIAOVIEN GV
WHERE NOT EXISTS (SELECT TG1.MADT
				  FROM THAMGIADT TG1 JOIN DETAI DT1 ON TG1.MADT = DT1.MADT
				  JOIN CHUDE CD1 ON CD1.MACD = DT1.MACD
				  WHERE CD1.TENCD = N'Ứng dụng công nghệ'
				  EXCEPT
				  SELECT TG2.MADT
				  FROM THAMGIADT TG2
				  WHERE TG2.MAGV = GV.MAGV
)

-- WHERE NOT EXISTS (...) 
-- => tạo 1 liên kết từ bảng dưới với bảng trên, thường cho 2 bảng giống nhau sẽ dễ hơn
-- => nếu SELECT có 2 thuộc tính thì tạo 2 liên kết như trên
SELECT * 
FROM GIAOVIEN GV
WHERE NOT EXISTS (SELECT TG1.MADT
				  FROM THAMGIADT TG1 JOIN DETAI DT1 ON TG1.MADT = DT1.MADT
				  JOIN CHUDE CD1 ON CD1.MACD = DT1.MACD
				  WHERE CD1.TENCD = N'Ứng dụng công nghệ'
				  AND NOT EXISTS (SELECT TG2.MADT
								  FROM THAMGIADT TG2
								  WHERE TG2.MAGV = GV.MAGV
								  AND TG1.MADT = TG2.MADT
								  )
)

-- WHERE ... NOT IN (...)
-- => lấy giá trị sau Select làm thành phần ... NOT IN
SELECT * 
FROM GIAOVIEN GV
WHERE NOT EXISTS (SELECT TG1.MADT
				  FROM THAMGIADT TG1 JOIN DETAI DT1 ON TG1.MADT = DT1.MADT
				  JOIN CHUDE CD1 ON CD1.MACD = DT1.MACD
				  WHERE CD1.TENCD = N'Ứng dụng công nghệ'
				  EXCEPT
				  SELECT TG2.MADT
				  FROM THAMGIADT TG2
				  WHERE TG2.MAGV = GV.MAGV
)

-- Q67. Cho biết tên đề tài nào
--	mà được tất cả các giáo viên
--	của khoa CNTT
--	tham gia.

SELECT DT.TENDT
FROM DETAI DT
WHERE NOT EXISTS (SELECT DISTINCT GV1.MAGV
				  FROM GIAOVIEN GV1 JOIN BOMON BM1 ON GV1.MABM = BM1.MABM
				  WHERE BM1.MAKHOA = N'CNTT'
				  EXCEPT
				  SELECT DISTINCT TG2.MAGV
				  FROM THAMGIADT TG2
				  WHERE TG2.MADT = DT.MADT
)

-- WHERE NOT EXISTS (...) 
-- => tạo 1 liên kết từ bảng dưới với bảng trên, thường cho 2 bảng giống nhau sẽ dễ hơn
-- => nếu SELECT có 2 thuộc tính thì tạo 2 liên kết như trên
SELECT DT.TENDT
FROM DETAI DT
WHERE NOT EXISTS (SELECT DISTINCT GV1.MAGV
				  FROM GIAOVIEN GV1 JOIN BOMON BM1 ON GV1.MABM = BM1.MABM
				  WHERE BM1.MAKHOA = N'CNTT'
				  AND NOT EXISTS (SELECT DISTINCT TG2.MAGV
								  FROM THAMGIADT TG2
								  WHERE TG2.MADT = DT.MADT
								  AND GV1.MAGV = TG2.MAGV
								  )
)

-- WHERE ... NOT IN (...)
-- => lấy giá trị sau Select làm thành phần ... NOT IN
SELECT DT.TENDT
FROM DETAI DT
WHERE NOT EXISTS (SELECT DISTINCT GV1.MAGV
				  FROM GIAOVIEN GV1 JOIN BOMON BM1 ON GV1.MABM = BM1.MABM
				  WHERE BM1.MAKHOA = N'CNTT'
				  AND GV1.MAGV NOT IN (SELECT DISTINCT TG2.MAGV
									   FROM THAMGIADT TG2
									   WHERE TG2.MADT = DT.MADT
									   )
)

-- Q69. Tìm tên các giáo viên
--	được phân công
--	làm tất cả các đề tài
--	có kinh phí trên 100 triệu

-- EXCEPT
SELECT GV.HOTEN AS N'Tên các giáo viên được phân công làm tất cả các đề tài có kinh phí trên 100 triệu'
FROM GIAOVIEN GV
WHERE NOT EXISTS (SELECT DISTINCT TG1.MADT
				  FROM THAMGIADT TG1 JOIN DETAI DT1 ON TG1.MADT = DT1.MADT
				  WHERE DT1.KINHPHI > 100
				  EXCEPT
				  SELECT DISTINCT TG2.MADT
				  FROM THAMGIADT TG2
				  WHERE GV.MAGV = TG2.MAGV
)

-- WHERE NOT EXISTS (...) 
-- => tạo 1 liên kết từ bảng dưới với bảng trên, thường cho 2 bảng giống nhau sẽ dễ hơn
-- => nếu SELECT có 2 thuộc tính thì tạo 2 liên kết như trên
SELECT GV.HOTEN AS N'Tên các giáo viên được phân công làm tất cả các đề tài có kinh phí trên 100 triệu'
FROM GIAOVIEN GV
WHERE NOT EXISTS (SELECT DISTINCT TG1.MADT
				  FROM THAMGIADT TG1 JOIN DETAI DT1 ON TG1.MADT = DT1.MADT
				  WHERE DT1.KINHPHI > 100
				  AND NOT EXISTS (SELECT DISTINCT TG2.MADT
								  FROM THAMGIADT TG2
								  WHERE GV.MAGV = TG2.MAGV
								  AND TG1.MADT = TG2.MADT
								  )
)

-- WHERE ... NOT IN (...)
-- => lấy giá trị sau Select làm thành phần ... NOT IN
SELECT GV.HOTEN AS N'Tên các giáo viên được phân công làm tất cả các đề tài có kinh phí trên 100 triệu'
FROM GIAOVIEN GV
WHERE NOT EXISTS (SELECT DISTINCT TG1.MADT
				  FROM THAMGIADT TG1 JOIN DETAI DT1 ON TG1.MADT = DT1.MADT
				  WHERE DT1.KINHPHI > 100
				  AND TG1.MADT NOT IN (SELECT DISTINCT TG2.MADT
									   FROM THAMGIADT TG2
									   WHERE GV.MAGV = TG2.MAGV
									   )
)

-- Q71. Cho biết mã số
--	, họ tên
--	, ngày sinh của giáo viên
--	tham gia tất cả các công việc
--	của đề tài “Ứng dụng hóa học xanh”.

SELECT DISTINCT GV.MAGV, GV.HOTEN, GV.NGSINH
FROM GIAOVIEN GV
WHERE EXISTS (SELECT DISTINCT CV1.MADT, CV1.SOTT
				  FROM THAMGIADT TG1 JOIN CONGVIEC CV1 ON TG1.MADT = CV1.MADT
				  JOIN DETAI DT1 ON DT1.MADT = TG1.MADT
				  WHERE DT1.TENDT = N'Ứng dụng hóa học xanh'
				  EXCEPT
				  SELECT DISTINCT CV2.MADT, TG2.STT
				  FROM CONGVIEC CV2 JOIN THAMGIADT TG2 ON TG2.MADT = CV2.MADT
				  WHERE TG2.MAGV = GV.MAGV
)

-- WHERE NOT EXISTS (...) 
-- => tạo 1 liên kết từ bảng dưới với bảng trên, thường cho 2 bảng giống nhau sẽ dễ hơn
-- => nếu SELECT có 2 thuộc tính thì tạo 2 liên kết như trên
SELECT DISTINCT GV.MAGV, GV.HOTEN, GV.NGSINH
FROM GIAOVIEN GV
WHERE NOT EXISTS (SELECT DISTINCT CV1.MADT, CV1.SOTT
				  FROM THAMGIADT TG1 JOIN CONGVIEC CV1 ON TG1.MADT = CV1.MADT
				  JOIN DETAI DT1 ON DT1.MADT = TG1.MADT
				  WHERE DT1.TENDT = N'Ứng dụng hóa học xanh'
				  AND NOT EXISTS (SELECT DISTINCT CV2.MADT, TG2.STT
								  FROM  CONGVIEC CV2 JOIN THAMGIADT TG2 ON TG2.MADT = CV2.MADT
								  WHERE TG2.MAGV = GV.MAGV
								  AND CV1.MADT = CV2.MADT
								  AND CV1.SOTT = TG2.STT
								  )
)

-- WHERE ... NOT IN (...)
-- => lấy giá trị sau Select làm thành phần ... NOT IN
SELECT DISTINCT GV.MAGV, GV.HOTEN, GV.NGSINH
FROM GIAOVIEN GV
WHERE EXISTS (SELECT DISTINCT CV1.MADT
				  FROM THAMGIADT TG1 JOIN CONGVIEC CV1 ON TG1.MADT = CV1.MADT
				  JOIN DETAI DT1 ON DT1.MADT = TG1.MADT
				  WHERE DT1.TENDT = N'Ứng dụng hóa học xanh'
				  AND CV1.MADT NOT IN (SELECT DISTINCT CV2.MADT
									   FROM CONGVIEC CV2 JOIN THAMGIADT TG2 ON TG2.MADT = CV2.MADT
									   WHERE TG2.MAGV = GV.MAGV
									   AND CV1.SOTT = TG2.STT
									   )
)

--------------------------------
-----Truy vấn lồng nâng cao-----
-------------BTTL#8-------------

-- MSSV: 20127578
-- Họ và tên: Phan Trí Nguyên
-- Lớp: 20CLC05

--	a. Cho biết danh sách tất cả giáo viên (magv, hoten)
--	và họ tên giáo viên
--	là quản lý chuyên môn của họ.

select DISTINCT GV.MAGV, GV.HOTEN, GV1.HOTEN
FROM GIAOVIEN GV LEFT JOIN GIAOVIEN GV1 ON GV1.GVQLCM = GV.MAGV

--b. Cho biết danh sách
--	tất cả bộ môn (mabm, tenbm)
--	, tên trưởng bộ môn
--	cùng số lượng giáo viên
--	của mỗi bộ môn.

select BM.MABM, BM.TENBM, GV.HOTEN, COUNT(*) AS N'Số lượng giáo viên'
FROM BOMON BM LEFT JOIN GIAOVIEN GV ON GV.MAGV = BM.TRUONGBM
LEFT JOIN GIAOVIEN GV1 ON GV.MABM = BM.MABM
GROUP BY BM.MABM, BM.TENBM, GV.HOTEN

--	c. Cho biết danh sách
--	tất cả các giáo viên nam
--	và thông tin các công việc mà
--	họ đã tham gia.

--select DISTINCT GV.MAGV, GV.HOTEN
--FROM GIAOVIEN GV FULL JOIN THAMGIADT TG ON TG.MAGV = GV.MAGV
--WHERE GV.PHAI = N'Nam' 
-- => danh sách tất cả các giáo viên nam

select DISTINCT GV.MAGV, GV.HOTEN, CV.TENCV
FROM GIAOVIEN GV FULL JOIN THAMGIADT TG ON TG.MAGV = GV.MAGV
LEFT JOIN CONGVIEC CV ON CV.MADT = TG.MADT
AND CV.SOTT = TG.STT
WHERE GV.PHAI = N'Nam' 

--	d. Cho biết danh sách
--	tất cả các giáo viên
--	và thông tin các công việc
--	thuộc đề tài 001 mà họ tham gia.

select DISTINCT GV.MAGV, GV.HOTEN, CV.TENCV
FROM GIAOVIEN GV LEFT JOIN THAMGIADT TG ON TG.MAGV = GV.MAGV
LEFT JOIN CONGVIEC CV ON CV.MADT = TG.MADT
AND TG.STT = CV.SOTT
WHERE TG.MADT = N'001'

--	e. Cho biết thông tin các trưởng bộ môn (magv, hoten)
--	sẽ về hưu vào năm 2014.
--	Biết rằng độ tuổi về hưu của giáo viên nam là 60
--	còn giáo viên nữ là 55.

-- tháng / ngày / năm
-- DATEDIFF(YEAR,A,B)
-- ngày kết thúc - ngày bắt đầu = INT
--		   B	 -	    A		= INT

--select BM.TRUONGBM, GV.HOTEN
--FROM GIAOVIEN GV RIGHT JOIN BOMON BM ON GV.MAGV = BM.TRUONGBM
--=> thông tin các trưởng bộ môn (magv, hoten)

select BM.TRUONGBM, GV.HOTEN, GV.NGSINH
FROM GIAOVIEN GV RIGHT JOIN BOMON BM ON GV.MAGV = BM.TRUONGBM
WHERE 2014 - YEAR(GV.NGSINH) >= (CASE GV.PHAI
								 WHEN N'Nam' THEN 60
								 WHEN N'Nữ' THEN 55
								 END
								 )

--	f. Cho biết thông tin các trưởng khoa (magv)
--	và năm họ sẽ về hưu.

select GV.MAGV AS N'magv trưởng khoa', (CASE GV.PHAI
				 WHEN N'Nam' THEN YEAR(GV.NGSINH) + 60
				 WHEN N'Nữ' THEN YEAR(GV.NGSINH) + 55
				 END
				 ) AS N'năm họ sẽ về hưu'
FROM KHOA K LEFT JOIN GIAOVIEN GV ON GV.MAGV = K.TRUONGKHOA

--	g. Tạo bảng DANHSACHTHIDUA (magv, sodtdat, danhhieu)
--	gồm thông tin mã giáo viên
--	, số đề tài họ tham gia
--	đạt kết quả và danh hiệu thi đua:
--		o Insert dữ liệu cho bảng này (để trống cột danh hiệu)
--		o Dựa vào cột sldtdat (số lượng đề tài tham gia có kết quả là “đạt”)
--		để cập nhật dữ liệu cho cột danh hiệu theo quy định:
--			 Sodtdat = 0 thì danh hiệu “chưa hoàn thành nhiệm vụ”
--			 1 <= Sodtdat <= 2 thì danh hiệu “hoàn thành nhiệm vụ”
--			 3 <= Sodtdat <= 5 thì danh hiệu “tiên tiến”
--			 Sodtdat >= 6 thì danh hiệu “lao động xuất sắc”
CREATE TABLE DANHSACHTHIDUA
(
	MAGV_1 char (5),
	SODTDAT INT,
	DANHHIEU NVARCHAR(50),
	PRIMARY KEY (MAGV_1)
)

select DISTINCT GV.MAGV AS N'mã giáo viên', COUNT(TG.KETQUA) AS N'số đề tài họ tham gia',(CASE
																		 WHEN COUNT(TG.KETQUA) = 0 THEN N'chưa hoàn thành nhiệm vụ'
																		 WHEN COUNT(TG.KETQUA) >= 1 AND COUNT(TG.KETQUA) <= 2 THEN N'hoàn thành nhiệm vụ'
																		 WHEN COUNT(TG.KETQUA) >= 3 AND COUNT(TG.KETQUA) <= 5 THEN N'tiên tiến'
																		 WHEN COUNT(TG.KETQUA) >= 6 THEN N'lao động xuất sắc'
																		 END
																		 ) AS N'danh hiệu thi đua'
FROM GIAOVIEN GV LEFT JOIN THAMGIADT TG ON TG.MAGV = GV.MAGV
AND TG.KETQUA = N'Đạt'
GROUP BY GV.MAGV

--	h. Cho biết magv
--	, họ tên
--	và mức lương các giáo viên nữ
--	của khoa “Công nghệ thông tin”
--	, mức lương trung bình,
--	mức lương lớn nhất
--	và nhỏ nhất của các giáo viên này.

select GV.MAGV, GV.HOTEN, GV.LUONG
FROM GIAOVIEN GV JOIN BOMON BM ON BM.MABM = GV.MABM
JOIN KHOA K ON K.MAKHOA = BM.MAKHOA
WHERE GV.PHAI = N'Nữ' AND K.TENKHOA = N'Công nghệ thông tin'

--COMPUTE AVG(GV.LUONG), MAX (LUONG), MIN(LUONG)

SELECT AVG(GV.LUONG), MAX (LUONG), MIN(LUONG)
FROM GIAOVIEN GV JOIN BOMON BM ON BM.MABM = GV.MABM
JOIN KHOA K ON K.MAKHOA = BM.MAKHOA
WHERE GV.PHAI = N'Nữ' AND K.TENKHOA = N'Công nghệ thông tin'

--	i. Cho biết makhoa
--	, tenkhoa
--	, số lượng gv từng khoa
--	, số lượng gv trung bình,
--	lớn nhất
--	và nhỏ nhất của các khoa này.

select K.MAKHOA, K.TENKHOA, COUNT(GV.MAGV)--, SUM(COUNT(*)), MAX(COUNT(*)), MIN(COUNT(*))
FROM KHOA K JOIN BOMON BM ON BM.MAKHOA = K.MAKHOA
JOIN GIAOVIEN GV ON GV.MABM = BM.MABM
GROUP BY K.MAKHOA, K.TENKHOA WITH ROLLUP

select * FROM BOMON BM
select * FROM CHUDE CD
select * FROM CONGVIEC CV
select * FROM DETAI DT
select * FROM GIAOVIEN GV
select * FROM GV_DT
select * FROM KHOA K
select * FROM NGUOITHAN NT
select * FROM THAMGIADT TG
--	j. Cho biết danh sách
--	các tên chủ đề
--	, kinh phí cho chủ đề (là kinh phí cấp cho các đề tài thuộc chủ đề)
--	, tổng kinh phí
--	, kinh phí lớn nhất
--	và nhỏ nhất cho các chủ đề.

--select SUM(DT.KINHPHI), MAX(DT.KINHPHI), MIN(DT.KINHPHI)
--FROM CHUDE CD JOIN DETAI DT ON CD.MACD = DT.MACD
-- tổng kinh phí, kinh phí lớn nhất và nhỏ nhất cho các chủ đề.

select CD.TENCD, DT.KINHPHI, SUM(DT.KINHPHI) AS N'Tổng kinh phí', MAX(DT.KINHPHI) AS N'Kinh phí lớn nhất', MIN(DT.KINHPHI) AS N'Kinh phí nhỏ nhất'
FROM CHUDE CD JOIN DETAI DT ON CD.MACD = DT.MACD
GROUP BY CD.TENCD, DT.KINHPHI WITH ROLLUP

--	m. Tổng hợp số lượng các đề tài
--	theo (cấp độ, chủ đề)
--	, theo (cấp độ)
--	, theo (chủ đề).

SELECT (CASE 
		WHEN DT.CAPQL IS NULL
		AND GROUPING(DT.CAPQL) = 1 THEN N'cấp độ BAT KI'
		ELSE DT.CAPQL
		END) AS N'cấp độ',
		(CASE
		WHEN DT.MACD IS NULL
		AND GROUPING(DT.MACD) = 1 THEN N'chủ đề BAT KI'
		ELSE DT.MACD
		END) AS N'chủ đề',
		COUNT(DT.MADT) AS N'số lượng các đề tài'
FROM DETAI DT
GROUP BY DT.CAPQL, DT.MACD WITH CUBE

select * FROM BOMON BM
select * FROM CHUDE CD
select * FROM CONGVIEC CV
select * FROM DETAI DT
select * FROM GIAOVIEN GV
select * FROM GV_DT
select * FROM KHOA K
select * FROM NGUOITHAN NT
select * FROM THAMGIADT TG
--	n. Tổng hợp mức lương tổng của các giáo viên
--	theo (bộ môn, phái)
--	, theo (bộ môn).

select (CASE
		WHEN GV.MABM IS NULL
		AND GROUPING(GV.MABM) = 1 THEN N'bộ môn bất kì'
		ELSE GV.MABM
		END) AS N'bộ môn',
		(CASE
		WHEN GV.PHAI IS NULL
		AND GROUPING(GV.PHAI) = 1 THEN N'phái bất kì'
		ELSE GV.PHAI
		END) AS N'phái',
		SUM(GV.LUONG) AS N'Tổng hợp mức lương tổng'
FROM GIAOVIEN GV
GROUP BY GV.MABM, GV.PHAI WITH ROLLUP

--	o. Tổng hợp số lượng các giáo viên
--	của khoa CNTT
--	theo (bộ môn, lương)
--	, theo (bộ môn)
--	, theo (lương).

select (CASE
		WHEN GV.MABM IS NULL
		AND GROUPING(GV.MABM) = 1 THEN N'bộ môn bất kì'
		ELSE GV.MABM
		END) AS N'bộ môn',
		(CASE
		WHEN GV.LUONG IS NULL
		AND GROUPING(GV.LUONG) = 1 THEN N'lương bất kì'
		ELSE GV.LUONG
		END) AS N'lương',
		COUNT(*)
FROM KHOA K JOIN BOMON BM ON BM.MAKHOA = K.MAKHOA
JOIN GIAOVIEN GV ON GV.MABM = BM.MABM 
AND K.MAKHOA = N'CNTT'
GROUP BY GV.MABM, GV.LUONG WITH CUBE


--------------------------------
-----Truy vấn lồng nâng cao-----
-------------BTVN#8-------------


-- Q75. Cho biết họ tên giáo viên
--	và tên bộ môn 
--	họ làm trưởng bộ môn nếu có


SELECT * FROM BOMON BM
SELECT * FROM CHUDE CD
SELECT * FROM CONGVIEC CV
SELECT * FROM DETAI DT
SELECT * FROM GIAOVIEN GV
SELECT * FROM GV_DT
SELECT * FROM KHOA K
SELECT * FROM NGUOITHAN NT
SELECT * FROM THAMGIADT TG
-- Q76. Cho danh sách 
--	tên bộ môn 
--	và họ tên trưởng bộ môn đó nếu có



SELECT * FROM BOMON BM
SELECT * FROM CHUDE CD
SELECT * FROM CONGVIEC CV
SELECT * FROM DETAI DT
SELECT * FROM GIAOVIEN GV
SELECT * FROM GV_DT
SELECT * FROM KHOA K
SELECT * FROM NGUOITHAN NT
SELECT * FROM THAMGIADT TG
--Q77. Cho danh sách 
--	tên giáo viên 
--	và các đề tài
--	giáo viên đó chủ nhiệm nếu có



--Q78. Xóa các đề tài
--	thuộc chủ đề “NCPT”.



SELECT * FROM BOMON BM
SELECT * FROM CHUDE CD
SELECT * FROM CONGVIEC CV
SELECT * FROM DETAI DT
SELECT * FROM GIAOVIEN GV
SELECT * FROM GV_DT
SELECT * FROM KHOA K
SELECT * FROM NGUOITHAN NT
SELECT * FROM THAMGIADT TG
--Q79. Xuất ra thông tin của giáo viên (MAGV, HOTEN)
--	và mức lương của giáo viên.
--	Mức lương được xếp theo quy tắc:
--		Lương của giáo viên < 1800 : “THẤP” ;
--		Từ 1800 đến 2200: TRUNG BÌNH;
--		Lương > 2200: “CAO”


SELECT * FROM BOMON BM
SELECT * FROM CHUDE CD
SELECT * FROM CONGVIEC CV
SELECT * FROM DETAI DT
SELECT * FROM GIAOVIEN GV
SELECT * FROM GV_DT
SELECT * FROM KHOA K
SELECT * FROM NGUOITHAN NT
SELECT * FROM THAMGIADT TG
--Q80. Xuất ra thông tin giáo viên (MAGV, HOTEN)
--	và xếp hạng dựa vào mức lương.
--	Nếu giáo viên có
--	lương cao nhất thì hạng là 1.


SELECT * FROM BOMON BM
SELECT * FROM CHUDE CD
SELECT * FROM CONGVIEC CV
SELECT * FROM DETAI DT
SELECT * FROM GIAOVIEN GV
SELECT * FROM GV_DT
SELECT * FROM KHOA K
SELECT * FROM NGUOITHAN NT
SELECT * FROM THAMGIADT TG
--Q81. Xuất ra thông tin thu nhập của giáo viên
--	. Thu nhập của giáo viên được tính bằng
--	LƯƠNG + PHỤ CẤP
--	. Nếu giáo viên là trưởng bộ môn thì
--	PHỤ CẤP là 300
--	, và giáo viên là trưởng khoa
--	thì PHỤ CẤP là 600.


SELECT * FROM BOMON BM
SELECT * FROM CHUDE CD
SELECT * FROM CONGVIEC CV
SELECT * FROM DETAI DT
SELECT * FROM GIAOVIEN GV
SELECT * FROM GV_DT
SELECT * FROM KHOA K
SELECT * FROM NGUOITHAN NT
SELECT * FROM THAMGIADT TG
--Q82. Xuất ra năm mà giáo viên dự kiến sẽ nghĩ hưu với quy định: Tuổi nghỉ hưu của Nam là
--60, của Nữ là 55.

SELECT * FROM BOMON BM
SELECT * FROM CHUDE CD
SELECT * FROM CONGVIEC CV
SELECT * FROM DETAI DT
SELECT * FROM GIAOVIEN GV
SELECT * FROM GV_DT
SELECT * FROM KHOA K
SELECT * FROM NGUOITHAN NT
SELECT * FROM THAMGIADT TG


--------------------------------
------------Ôn Tập--------------
--------------------------------

-- làm chơi, ko có thi :)))
SELECT * FROM THAMGIADT

GO
CREATE TRIGGER TGPHANCONG
ON THAMGIADT
FOR INSERT
AS
	BEGIN
		SELECT * FROM inserted
		SELECT * FROM deleted
		SELECT * FROM THAMGIADT
		IF EXISTS (SELECT COUNT(*) FROM THAMGIADT TG JOIN inserted I ON
		i.MAGV = TG.MAGV AND I.MADT = TG.MADT
		GROUP BY TG.MAGV, TG.MADT
		HAVING COUNT(*) > 2
		)
		BEGIN
		
			ROLLBACK
		END
	END
GO
--TRUY VAN LONG
--PHEP CHIA
--STORE PROCEDURE
--FUNCTION
-----
--1. 	Viết stored thực hiện
--	phân công 1 giảng viên tham gia 1 công việc của 1 đề tài cụ thể
--	. Lưu ý: mỗi giảng viên chỉ được tham gia tối đa 3 công việc của 1 đề tài
--	. Nếu vi phạm thì báo lỗi không thực hiện phân công
--SELECT MAGV, MADT, COUNT(STT) AS SLCV
--FROM THAMGIADT
--GROUP BY MAGV, MADT

GO
IF object_id('SP_PHANCONGGV','P') IS NOT NULL
	DROP PROC IF EXISTS SP_PHANCONGGV;
GO
CREATE PROCEDURE SP_PHANCONGGV 
				@MAGV char(5),
				@MADT CHAR(3)
AS
	-- GIAOVIEN
	IF (NOT EXISTS (SELECT * FROM GIAOVIEN GV WHERE GV.MAGV = @MAGV))
	BEGIN
		RAISERROR (N'Giáo viên không tồn tại!', 0, 1)
		RETURN
	END

	-- DETAI
	IF (NOT EXISTS (SELECT * FROM DETAI DT WHERE DT.MADT = @MAGV))
	BEGIN
		RAISERROR (N'Mã đề tài không tồn tại!', 0, 1)
		RETURN
	END



	-- TOI DA 3 CONG VIEC TRONG 1 DE TAI
	DECLARE @SLCV INT
	IF (EXISTS (SELECT TG.MAGV, TG.MADT
				FROM THAMGIADT TG
				WHERE TG.MAGV = @MAGV AND TG.MADT = @MADT
				GROUP BY TG.MAGV, TG.MADT
				HAVING COUNT(STT) >= 3
				) 
		)
				BEGIN
					RAISERROR (N'SO LUONG CONG VIEC MA GIAO VIEN THAM GIA PHAI NHO HON 3.', 0, 1)
					RETURN
				END
GO
EXEC SP_PHANCONGGV '001','001'
SELECT * FROM THAMGIADT

--2. 	Viết store thực hiện
--	cập nhật ngày kết thúc của dự án
--	. Lưu ý, ngày kết thúc phải sau ngày bắt đầu theo quy định:
--		Đề tài cấp trường: thời gian thực hiện tối thiểu là 3 tháng, tối đa là 6 tháng
--		Đề tài cấp ĐHQG thời gian thực hiện tối thiểu là 6 tháng, tối đa là 9 tháng
--		Đề tài cấp nhà nước thời gian thực hiện tối thiểu là 12 tháng, tối đa là 24 tháng

GO
IF object_id('SP_CapNhatDuAn','P') IS NOT NULL
	DROP PROC SP_CapNhatDuAn
GO
CREATE PROC SP_CapNhatDuAn @MADT char(3),
						   @NGAYKT datetime
AS
	-- KIEM TRA MADT CO TON TAI
	IF (NOT EXISTS (SELECT * FROM DETAI DT WHERE DT.MADT = @MADT))
	BEGIN
		RAISERROR (N'Mã đề tài không tồn tại!', 0, 1)
		RETURN
	END

	DECLARE @CAP NVARCHAR(40)
	DECLARE @NGAYBD DATE
	
	SELECT @NGAYBD = DT.NGAYBD, @CAP = DT.CAPQL
	FROM DETAI DT

	DECLARE @TIME INT
	SET @TIME = DATEDIFF(MONTH,@NGAYBD, @NGAYKT)

	PRINT CAST (@TIME AS VARCHAR(20))

	IF (@CAP = N'Trường' AND @TIME > 3 AND @TIME < 6)
	begin
		UPDATE DETAI SET NGAYKT = @NGAYKT
		PRINT N'Cập nhật ngày kết thúc thành công !'
		
		--CAST (@MAGV AS VARCHAR(10)
	end
	ELSE IF (@CAP = N'ĐHQG' AND @TIME > 6 AND @TIME < 9)
	begin
		UPDATE DETAI SET NGAYKT = @NGAYKT
		PRINT N'Cập nhật ngày kết thúc thành công !'
	end
	ELSE IF (@CAP = N'Nhà nước' AND @TIME > 12 AND @TIME < 24)
	begin
		UPDATE DETAI SET NGAYKT = @NGAYKT
		PRINT N'Cập nhật ngày kết thúc thành công !'
	end

	ELSE 
		PRINT N'Thông tin không thể cập nhật !'
GO
EXEC SP_CapNhatDuAn '007','2009-10-10 00:00:00.000'


SELECT *
FROM GIAOVIEN GV1 JOIN GIAOVIEN GV2 ON GV1.MABM = GV2.MABM
WHERE GV1.MAGV != GV2.GVQLCM

--3. Viết store thực hiện
--	cập nhật giáo viên quản lý chuyên môn cho 1 giảng viên cụ thể
--	. Lưu ý, GVQLCM phải cùng bộ môn
--	với giảng viên cần cập 
GO
IF object_id('SP_CapNhatGiaoVien','P') IS NOT NULL
	DROP PROC SP_CapNhatGiaoVien
GO
CREATE PROC SP_CapNhatGiaoVien @MAGV CHAR(5), @GVQLCM char(5)
AS
	-- KIEM TRA giáo viên quản lý chuyên môn CO TON TAI ko
	IF (NOT EXISTS (SELECT * FROM GIAOVIEN GV WHERE GV.MAGV = @GVQLCM))
	BEGIN
		RAISERROR (N'Mã giáo viên quản lí chuyên môn không tồn tại!', 0, 1)
		RETURN
	END

	-- kiểm tra giảng viên cần cập có tồn tại ko ?
	IF (NOT EXISTS (SELECT * FROM GIAOVIEN GV WHERE GV.MAGV = @MAGV))
	BEGIN
		RAISERROR (N'Mã giảng viên không tồn tại!', 0, 1)
		RETURN
	END

	-- thực hiện việc cập nhật nếu 2 giáo viên cùng 1 bộ môn
	IF (NOT EXISTS (SELECT *
					  FROM GIAOVIEN GV1 JOIN GIAOVIEN GV2 ON GV1.MABM = GV2.MABM 
					  AND GV1.MAGV = @GVQLCM 
					  AND GV2.MAGV = @MAGV)
		)
	begin
		UPDATE GIAOVIEN SET GVQLCM = @GVQLCM WHERE MAGV = @MAGV
		PRINT N'Cập nhật giáo viên quản lý chuyên môn thành công !'
	end

	ELSE 
		PRINT N'Thông tin không thể cập nhật !'
GO
EXEC SP_CapNhatGiaoVien '002', '001'

--4. Viết function đếm
--	số đề tài tham gia của 1 magv
GO
IF object_id('F_DemSoDeTai','P') IS NULL
	DROP FUNCTION F_DemSoDeTai
GO
CREATE FUNCTION F_DemSoDeTai ( @MaGV CHAR(5) )
RETURNS INT
BEGIN
	declare @sldttg int
	select @sldttg = T.SLDT
	FROM (SELECT GV.MAGV, COUNT(TG.MADT) AS SLDT
		  FROM THAMGIADT TG right join GIAOVIEN GV on TG.MAGV = GV.MAGV
		  GROUP BY GV.MAGV) as T
	WHERE T.MAGV = @MaGV
 
	RETURN @sldttg
END

GO
DECLARE @MAGV VARCHAR(5)
SET @MAGV = '006'
PRINT N'Số đề tài tham gia của giáo viên với Mã GV ' + CAST (@MAGV AS VARCHAR(5)) + N' là: ' + CAST (DBO.F_DemSoDeTai(@MAGV) AS VARCHAR(10))
--PRINT DBO.F_DemSoDeTai(@MAGV)

-- HÀM XỬ LÍ
--SELECT gv.MAGV, COUNT(tg.MADT) AS SLDT
--FROM THAMGIADT TG right join GIAOVIEN gv on TG.MAGV = gv.MAGV
--GROUP BY gv.MAGV
--

--5. Viết stored xuất danh sách 
--	(magv, ho ten, ten bo mon) 
--	của các giảng viên tham gia trên 3 đề tài 
--	(gọi lại function câu 4)
GO
IF object_id('SP_DanhSachCau5','P') IS NOT NULL
	 drop PROC SP_DanhSachCau5
GO
CREATE PROC SP_DanhSachCau5 
AS
BEGIN	
	-- số lượng đề tài của từng giáo viên
	--DECLARE @SLDT INT
	--SELECT @SLDT = DBO.F_DemSoDeTai(@MAGV)
	--IF (@SLDT > 3)

	-- lấy danh sách toàn bộ giáo viên
	select gv.MAGV, gv.HOTEN, bm.TENBM
	from GIAOVIEN gv join BOMON bm on gv.MABM = bm.MABM
	where DBO.F_DemSoDeTai(gv.MAGV) > 3
END

GO
EXEC SP_DanhSachCau5

--6. Viết function 
--	đếm số đề tài chủ nhiệm của 1 magv
GO
IF object_id('SP_DanhSachCau5','P') IS NOT NULL
	 drop FUNCTion F_DemSoDeTaiChuNhiem
GO
CREATE FUNCTION F_DemSoDeTaiChuNhiem ( @MaGV CHAR(5) )
RETURNS INT
BEGIN

	declare @SLDTCN int
	select @SLDTCN = T.SLDTCN
	FROM (SELECT GV.MAGV, COUNT(DT.MADT) AS SLDTCN
		  FROM GIAOVIEN GV JOIN DETAI DT ON DT.GVCNDT = GV.MAGV
		  GROUP BY GV.MAGV) as T
	WHERE T.MAGV = @MaGV
 
	RETURN @SLDTCN
END

GO
DECLARE @MAGV VARCHAR(5)
SET @MAGV = '006'

	-- kiểm tra giảng viên nhập có phải là giáo viên chủ nhiệm đề tài ko ?
IF (NOT EXISTS (SELECT * FROM GIAOVIEN GV WHERE GV.MAGV = @MAGV))
	BEGIN
		RAISERROR (N'Mã giảng viên không tồn tại !', 0, 1)
	END
ELSE IF (NOT EXISTS (SELECT * FROM DETAI DT WHERE DT.GVCNDT = @MAGV))
	BEGIN
		RAISERROR (N'Giảng viên không phải là giáo viên chủ nhiệm đề tài!', 0, 1)
	END
ELSE
	BEGIN
		PRINT N'Số đề tài chủ nhiệm của giáo viên với Mã GV ' + CAST (@MAGV AS VARCHAR(5)) + N' là: ' + CAST( DBO.F_DemSoDeTaiChuNhiem(@MAGV) AS VARCHAR(5))
		--PRINT DBO.F_DemSoDeTaiChuNhiem(@MAGV)
	END


-- DANH SÁCH GIÁO VIÊN CHỦ NHIỆM CÁC ĐỀ TÀI
GO
SELECT GV.MAGV, COUNT(DT.MADT)
FROM GIAOVIEN GV JOIN DETAI DT ON DT.GVCNDT = GV.MAGV
GROUP BY GV.MAGV
--
--7. Viết stored xuất danh sách 
--	(magv, họ tên, số đề tài chủ nhiệm)
--	của mỗi giảng viên
--	thuộc bộ môn HTTT.

GO
IF object_id('SP_DanhSachGV_HTTT','P') IS NOT NULL
	DROP PROC SP_DanhSachGV_HTTT
GO
CREATE PROC SP_DanhSachGV_HTTT
AS
BEGIN
	SELECT GV.MAGV, GV.HOTEN, COUNT(DT.MADT) AS N'Số đề tài chủ nhiệm'
	FROM GIAOVIEN GV JOIN DETAI DT ON DT.GVCNDT = GV.MAGV
	WHERE GV.MABM = N'HTTT'
	GROUP BY GV.MAGV, GV.HOTEN
END
GO
EXEC SP_DanhSachGV_HTTT

--------------------------------
--------------------------------
--------------------------------
--SELECT * FROM CHUDE CD
--SELECT * FROM CONGVIEC CV
--SELECT * FROM DETAI DT
--SELECT * FROM GIAOVIEN GV
--SELECT * FROM GV_DT
--SELECT * FROM KHOA K
--SELECT * FROM NGUOITHAN NT
--SELECT * FROM THAMGIADT TG