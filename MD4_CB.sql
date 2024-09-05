create database MD4_CB;
use MD4_CB;

CREATE TABLE Books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    book_title VARCHAR(100) NOT NULL,
    book_author VARCHAR(100) NOT NULL
);

CREATE TABLE readers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(150) NOT NULL,
    phone VARCHAR(11) UNIQUE NOT NULL,
    email VARCHAR(100),
    INDEX id_name (name)
);

CREATE TABLE BorrowingRecords (
    id INT PRIMARY KEY AUTO_INCREMENT,
    borrow_date DATE NOT NULL,
    return_date DATE,
    book_id INT NOT NULL,
    reader_id INT NOT NULL
);

alter table BorrowingRecords add foreign key (book_id) references Books(book_id);
alter table BorrowingRecords add foreign key (reader_id) references readers(id);

INSERT INTO Books (book_title, book_author) VALUES
('Tôi Thấy Hoa Vàng Trên Cỏ Xanh', 'Nguyễn Nhật Ánh'),
('Đắc Nhân Tâm', 'Dale Carnegie'),
('Tuổi Thơ Dữ Dội', 'Phùng Quán'),
('Nhà Giả Kim', 'Paulo Coelho'),
('Cánh Đồng Bất Tận', 'Nguyễn Ngọc Tư');


INSERT INTO readers (name, phone, email) VALUES
('Nguyễn Văn An', '0901234567', 'nguyenvanan@example.com'),
('Trần Thị Bích', '0901234568', 'tranthibich@example.com'),
('Lê Văn Cường', '0901234569', 'levancuong@example.com'),
('Hoàng Thị Dung', '0901234570', 'hoangthidung@example.com'),
('Phạm Văn Đức', '0901234571', 'phamvanduc@example.com'),
('Nguyễn Thị Lan', '0901234572', 'nguyenthilan@example.com'),
('Trần Văn Minh', '0901234573', 'tranvanminh@example.com'),
('Lê Thị Hoa', '0901234574', 'lethihoa@example.com'),
('Hoàng Văn Long', '0901234575', 'hoangvanlong@example.com'),
('Phạm Thị Phương', '0901234576', 'phamthiphuong@example.com'),
('Nguyễn Văn Khải', '0901234577', 'nguyenvankhai@example.com'),
('Trần Thị Hương', '0901234578', 'tranthihuong@example.com'),
('Lê Văn Tú', '0901234579', 'levantu@example.com'),
('Hoàng Thị Mai', '0901234580', 'hoangthimai@example.com'),
('Phạm Văn Hưng', '0901234581', 'phamvanhung@example.com');


INSERT INTO BorrowingRecords (borrow_date, return_date, book_id, reader_id) VALUES
('2023-09-01', '2023-09-10', 1, 1),
('2023-09-05', '2023-09-29', 3, 4),
('2023-09-08', '2023-09-15', 5, 2);

select * from Books;
select * from readers;
select * from BorrowingRecords;

-- yêu cầu 1:
-- 1. Viết truy vấn SQL để lấy thông tin tất cả các giao dịch mượn sách, bao gồm tên sách, tên 
-- độc giả, ngày mượn, và ngàytrả

SELECT 
    b.book_title, b.book_author, br.borrow_date, br.return_date
FROM
    BorrowingRecords br
        JOIN
    books b ON b.book_id = br.book_id;

-- 2. Viết truy vấn SQL để tìm tất cả các sách mà độc giả bất kỳ đã mượn.

SELECT 
    r.name AS reader_name,
    b.book_title,
    b.book_author,
    br.borrow_date,
    br.return_date
FROM
    BorrowingRecords br
        JOIN
    books b ON b.book_id = br.book_id
        JOIN
    readers r ON r.id - br.reader_id;

-- 3.Đếm số lần một cuốn sách đã được mượn.

SELECT 
    b.book_title,
    b.book_author,
    COUNT(id) AS 'so lan muon 1 cuon sach'
FROM
    BorrowingRecords br
        JOIN
    books b ON b.book_id = br.book_id
GROUP BY b.book_id;

-- 4.Truy vấn tên của độc giả đã mượn nhiều sách nhất.
-- SELECT 
--     r.name AS reader_name,
--     b.book_title,
--     b.book_author,
--     COUNT(br.book_id) AS books_borrowed
-- FROM
--     BorrowingRecords br
--         JOIN
--     books b ON b.book_id = br.book_id
--         JOIN
--     readers r ON r.id = br.reader_id
-- GROUP BY r.name
-- ORDER BY books_borrowed DESC
-- LIMIT 1;

SELECT 
    r.name AS reader_name,
    COUNT(br.book_id) AS books_borrowed
FROM
    BorrowingRecords br
        JOIN
    readers r ON r.id = br.reader_id
GROUP BY 
    r.name
ORDER BY 
    books_borrowed DESC
LIMIT 1;

-- yêu cầu 2
-- Tạo một view tên là borrowed_books để hiển thị thông tin của tất cả các sách đã được 
-- mượn, bao gồm tên sách, tên độc giả, và ngày mượn. Sử dụng các bảng Books, Readers, và 
-- BorrowingRecords.
 drop view borrowed_books;
 CREATE VIEW borrowed_books AS
    SELECT 
        r.name AS reader_name,
        b.book_title,
        b.book_author,
        br.borrow_date,
        br.return_date
    FROM
        BorrowingRecords br
            JOIN
        books b ON b.book_id = br.book_id
            JOIN
        readers r ON r.id - br.reader_id;

-- yêu cầu 3 
-- 1. Viết một thủ tục tên là get_books_borrowed_by_reader nhận một tham số là 
-- reader_id . Thủ tục này sẽ trả về danh sách các sách mà độc giả đó đã mượn, bao gồm tên 
-- sách và ngày mượn. 
DELIMITER $$
CREATE PROCEDURE get_books_borrowed_by_reader(IN p_reader_id INT)
BEGIN
    SELECT 
        b.book_title,
        br.borrow_date
    FROM 
        BorrowingRecords br
        JOIN Books b ON br.book_id = b.book_id
    WHERE 
        br.reader_id = p_reader_id;
END$$
DELIMITER ;

call get_books_borrowed_by_reader(1);

-- yêu cầu 4
-- 1. Tạo một Trigger trong MySQL để tự động cập nhật ngày trả sách trong bảng 
-- BorrowingRecords khi cuốn sách được trả. Cụ thể, khi một bản ghi trong bảng 
-- BorrowingRecords được cập nhật với giá trị return_date , Trigger sẽ ghi lại ngày hiện tại 
-- (ngày trả sách) nếu return_date chưa được điền trước đó.
drop trigger update_return_date;
DELIMITER $$
CREATE trigger update_return_date
before update on BorrowingRecords
for each row
BEGIN
    if new.return_date is null 
    then set new.return_date = curdate();
    end if;
        END$$
DELIMITER ;








