-- Flight Service
CREATE DATABASE IF NOT EXISTS aerobook;
CREATE USER IF NOT EXISTS 'aerobook_user'@'%' IDENTIFIED BY 'aerobook123!';
GRANT ALL PRIVILEGES ON aerobook.* TO 'aerobook_user'@'%';

-- User Service
CREATE DATABASE IF NOT EXISTS aerobook_users;
CREATE USER IF NOT EXISTS 'user'@'%' IDENTIFIED BY 'user';
GRANT ALL PRIVILEGES ON aerobook_users.* TO 'user'@'%';

-- Booking Service
CREATE DATABASE IF NOT EXISTS aerobook_booking;
CREATE USER IF NOT EXISTS 'aerobookbookinguser'@'%' IDENTIFIED BY 'aerobook';
GRANT ALL PRIVILEGES ON aerobook_booking.* TO 'aerobookbookinguser'@'%';

-- Payment Service
CREATE DATABASE IF NOT EXISTS aerobook_payment;
CREATE USER IF NOT EXISTS 'aerobookpaymentuser'@'%' IDENTIFIED BY 'payment';
GRANT ALL PRIVILEGES ON aerobook_payment.* TO 'aerobookpaymentuser'@'%';

-- Notification Service
CREATE DATABASE IF NOT EXISTS notification_db;
CREATE USER IF NOT EXISTS 'notification_user'@'%' IDENTIFIED BY 'noti';
GRANT ALL PRIVILEGES ON notification_db.* TO 'notification_user'@'%';

FLUSH PRIVILEGES;