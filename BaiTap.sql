create database QLMH;
go
use QLMH;
go

create table CUSTOMER(
	maKH varchar(10) primary key,
	hoten varchar(100),
	email varchar(100),
	sdt varchar(10),
	diachi varchar(100)
)

create table PAYMENT(
	maTT varchar(10) primary key,
	tenPTTT varchar(100),
	phiTT money
)

create table ORDERS(
	maDH varchar(10) primary key,
	ngaydat date,
	trangthai varchar(10),
	tongtien money,
	maKH varchar(10),
	maTT varchar(10)
)

create table PRODUCT(
	maSP varchar(10) primary key,
	tenSP varchar(100),
	mota varchar(100),
	giaSP money,
	soluongSP int
)

create table ORDER_DETAILS(
	maCTSP varchar(10) primary key,
	soluongmua int,
	gia money,
	thanhtien money,
	maDH varchar(10),
	maSP varchar(10)
)

alter table ORDERS add foreign key(maKH) references CUSTOMER(maKH)
alter table ORDERS add foreign key(maTT) references PAYMENT(maTT)
alter table ORDER_DETAILS add foreign key(maDH) references ORDERS(maDH)
alter table ORDER_DETAILS add foreign key(maSP) references PRODUCT(maSP)

INSERT INTO CUSTOMER VALUES
--MaKH            hoten            email            sdt            diachi
('MKH01','Nguyen Van Dung',    'dung@gmail.com','0845123456','Hai Chau'),
('MKH02','Nguyen Van Minh',    'minh@gmail.com','0845123456','Lien Chieu'),
('MKH03','Le Van Long',        'long@gmail.com','0845123456','Hoa Vang');

INSERT INTO PAYMENT VALUES
--MaTT        TenTTT        PhiTT
('MaTT01',    'MOMO',        10000),
('MaTT02',    'ATM',        10000);

INSERT INTO ORDERS VALUES
--MaDH        ngaydat            trangthai    tongtien    MaKH    MaTT
('MDH01',    '2016/10/20',    'Cho Xu Ly',7000000,        'MKH01','MaTT01'),
('MDH02',    '2018/10/19',    'Cho Xu Ly',9000000,        'MKH01','MaTT01'),
('MDH03',    '2020/10/09',    'Da Xu Ly',    6000000,        'MKH01','MaTT01');

INSERT INTO PRODUCT VALUES
--MaSP    tenSP        mota            giaSP    soluongSP
('SP01','samsum',    'android 9.0',    6000000,10),
('SP02','oppo',        'android 8.0',    7000000,10),
('SP03','vivo',        'android 7.0',    9000000,10);

INSERT INTO ORDER_DETAILS VALUES
('CTSP01',1,600000,6010000,'MDH03','SP01'),
('CTSP02',1,700000,7010000,'MDH01','SP02'),
('CTSP03',1,900000,9010000,'MDH02','SP03');

--VIEW
-- xem khach hang co trang thai don hang la 'Cho xu ly'
go
create view V_Customer_Processing
as
select customer.*, ORDERS.trangthai from CUSTOMER
inner join ORDERS on CUSTOMER.maKH = ORDERS.maKH
where ORDERS.trangthai = 'Cho Xu Ly'

--drop view V_Customer_Processing

select * from V_Customer_Processing

--PROCEDURE
--proc them san pham
go
create proc P_AddProduct(
	@maSP varchar(10),
	@tenSP varchar(100),
	@mota varchar(100),
	@giaSP money,
	@soluongSP int
)
as
begin
	if exists(select maSP from PRODUCT
	where maSP = @maSP)
	begin
		print N'Mã sản phẩm đã tồn tại'
		return
	end
	insert into PRODUCT
	values (@maSP, @tenSP, @mota, @giaSP, @soluongSP)
end

exec P_AddProduct @maSP = 'SP08', @tenSP = 'Iphone 13', @mota = 'khong', @giaSP = '9000000', @soluongSP = 10;
exec P_AddProduct @maSP = 'SP02', @tenSP = 'Iphone 13', @mota = 'khong', @giaSP = '9000000', @soluongSP = 10;
exec P_AddProduct @maSP = 'SP04', @tenSP = 'BlackBerry Bold', @mota = 'khong', @giaSP = '500000', @soluongSP = 10;
exec P_AddProduct @maSP = 'SP05', @tenSP = 'BlackBerry Classic', @mota = 'khong', @giaSP = '9000000', @soluongSP = 10;

select * from PRODUCT

go
create proc P_UpdateCustomer(
	@maKH varchar(10),
	@name nvarchar(50),
	@email varchar(50),
	@phone nvarchar(50),
	@adress nvarchar(50)
)
as
begin
	if not exists(select maKH from CUSTOMER
	where maKH = @maKH)
	begin
		print N'Khách hàng không tồn tại!'
		return
	end
	update CUSTOMER
	set hoten = @name, email = @email, sdt = @phone, diachi = @adress
	where maKH = @maKH
end

exec P_UpdateCustomer @maKH = 'MKH01', @name = 'Nguyen Duong Quy',@email = 'email@gmail.com', @phone = '0912312312', @adress = 'Quang Tri'
exec P_UpdateCustomer @maKH = 'MKH02', @name = 'Nguyen Huu Phuoc',@email = 'phuoc@edu.udn.vn', @phone = '0912312312', @adress = 'Quang Nam'

select * from CUSTOMER

-- them 1 oder moi, kiem tra tinh toan ven cua du lieu
go
create proc P_AddOders(
	@maDH varchar(10),
	@ngaydat date,
	@trangthai nvarchar(50),
	@tongtien money,
	@maKH varchar(10),
	@maTT varchar(10)
)
as
begin
	if exists (select maDH from ORDERS where maDH = @maDH)
	begin
		print N'Mã đơn hàng đã tồn tại'
		return
	end
	if not exists (select maKH from CUSTOMER where maKH = @maKH)
	begin
		print N'Khách hàng không tồn tại'
		return
	end
	if not exists (select maTT from PAYMENT where maTT = @maTT)
	begin
		print N'Phương thức thanh toán không tồn tại'
		return
	end
	insert into ORDERS
	values(@maDH, @ngaydat, @trangthai, @tongtien, @maKH, @maTT)
end
exec P_AddOders @maDH = 'MDH04', @ngaydat = '2/3/2021', @trangthai = 'Cho Xu Ly', @tongtien = 100000, @maKH = 'MKH01', @maTT = 'MaTT01'

select * from ORDERS
select * from CUSTOMER
select * from PAYMENT


--FUNCTION
--ham tim khach hang = maKH
go
create function F_findCustomerByMaHK(@MaKH varchar(10))
returns table
as
return
	select * from CUSTOMER
	where maKH = @MaKH;

select * from F_findCustomerByMaHK('MKH01')

