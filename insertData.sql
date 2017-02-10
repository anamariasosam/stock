/*
SQLyog Community v12.4.0 (64 bit)
MySQL - 5.7.14 : Database - udem_inventario
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

/*Data for the table `entradas` */

insert  into `entradas`(`id`,`feentrada`,`persona_id`) values

(1,'2017-02-10 06:50:54',4),

(2,'2017-02-10 06:52:18',2);

/*Data for the table `entradas_productos` */

insert  into `entradas_productos`(`id`,`nmcantidad`,`entrada_id`,`producto_id`,`nmcantidad_disponible`,`nmvalor_unitario`) values

(1,20,1,2,20,500.00),

(2,5,1,3,5,3000.00),

(3,20,2,2,20,550.00);

/*Data for the table `personas` */

insert  into `personas`(`id`,`name`,`direccion`) values

(1,'Casimiro','c1'),

(2,'Romulo','c2'),

(3,'Bonifacio','c3'),

(4,'Rapunsel','c4');

/*Data for the table `productos` */

insert  into `productos`(`id`,`name`,`nmcantidad_disponible`,`nmsuma_cantidad_total`,`nmsuma_valor_total`) values

(1,'C Terapeutico',0,0,0.00),

(2,'Fresas',40,40,21000.00),

(3,'Brownis',5,5,15000.00);

/*Data for the table `productos_salidas` */

/*Data for the table `salidas` */

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
