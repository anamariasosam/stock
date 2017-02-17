/*
SQLyog Community v12.2.5 (64 bit)
MySQL - 5.5.24-log : Database - udem_inventario
*********************************************************************
*/


/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
CREATE DATABASE /*!32312 IF NOT EXISTS*/`udem_inventario` /*!40100 DEFAULT CHARACTER SET utf8 */;

USE `udem_inventario`;

insert  into `entradas`(`id`,`feentrada`,`persona_id`) values

(5,'2016-08-25 10:57:37',3),

(6,'2016-08-26 10:57:50',3),

(7,'2016-08-27 11:00:05',3);

insert  into `entradas_productos`(`id`,`nmcantidad`,`entrada_id`,`producto_id`,`psvalor_unitario`,`nmcantidad_disponible`) values

(7,20,5,3,'50000.00',20),

(8,20,5,4,'30000.00',20),

(10,20,5,5,'1000.00',20),

(11,10,6,3,'55000.00',10),

(12,10,6,4,'25000.00',10),

(13,10,6,5,'1000.00',10),

(14,20,7,3,'50000.00',20),

(15,20,7,4,'30000.00',20),

(16,30,7,6,'60000.00',30);


insert  into `personas`(`id`,`name`,`direccion`) values

(3,'Hugo',NULL),

(4,'Paco',NULL),

(5,'Luis',NULL);


insert  into `productos`(`id`,`name`,`nmcantidad`,`pssuma_total_valores`,`nmsuma_total_productos`,`psventa`) values 

(3,'Vino',50,'2550000.00',50,'66000.00'),

(4,'Queso',50,'1200000.00',50,'36000.00'),

(5,'Aceituna',30,'30000.00',30,'1200.00'),

(6,'Jamon',30,'1800000.00',30,'72000.00');
