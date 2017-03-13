# ************************************************************
# Sequel Pro SQL dump
# Version 4541
#
# http://www.sequelpro.com/
# https://github.com/sequelpro/sequelpro
#
# Host: 127.0.0.1 (MySQL 5.5.5-10.1.21-MariaDB)
# Database: udem_inventario
# Generation Time: 2017-03-13 02:36:13 +0000
# ************************************************************


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


# Dump of table entradas
# ------------------------------------------------------------

DROP TABLE IF EXISTS `entradas`;

CREATE TABLE `entradas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `feentrada` datetime DEFAULT NULL,
  `persona_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_entradas_clientes_idx` (`persona_id`),
  CONSTRAINT `fk_entradas_clientes` FOREIGN KEY (`persona_id`) REFERENCES `personas` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `entradas` WRITE;
/*!40000 ALTER TABLE `entradas` DISABLE KEYS */;

INSERT INTO `entradas` (`id`, `feentrada`, `persona_id`)
VALUES
	(1,'2016-02-27 00:00:00',3);

/*!40000 ALTER TABLE `entradas` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table entradas_productos
# ------------------------------------------------------------

DROP TABLE IF EXISTS `entradas_productos`;

CREATE TABLE `entradas_productos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nmcantidad` int(11) DEFAULT NULL,
  `entrada_id` int(11) NOT NULL,
  `producto_id` int(11) NOT NULL,
  `psvalor_unitario` decimal(10,2) DEFAULT NULL,
  `nmcantidad_disponible` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_entradas_productos_entradas1_idx` (`entrada_id`),
  KEY `fk_entradas_productos_productos1_idx` (`producto_id`),
  CONSTRAINT `fk_entradas_productos_entradas1` FOREIGN KEY (`entrada_id`) REFERENCES `entradas` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_entradas_productos_productos1` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `entradas_productos` WRITE;
/*!40000 ALTER TABLE `entradas_productos` DISABLE KEYS */;

INSERT INTO `entradas_productos` (`id`, `nmcantidad`, `entrada_id`, `producto_id`, `psvalor_unitario`, `nmcantidad_disponible`)
VALUES
	(1,10,1,5,200.00,10);

/*!40000 ALTER TABLE `entradas_productos` ENABLE KEYS */;
UNLOCK TABLES;

DELIMITER ;;
/*!50003 SET SESSION SQL_MODE="STRICT_TRANS_TABLES,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ALLOW_INVALID_DATES,ERROR_FOR_DIVISION_BY_ZERO,TRADITIONAL,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION" */;;
/*!50003 CREATE */ /*!50017 DEFINER=`root`@`localhost` */ /*!50003 TRIGGER `entradas_productos_bi` BEFORE INSERT ON `entradas_productos` FOR EACH ROW BEGIN
	DECLARE v_pscompra DECIMAL(10,2);
	DECLARE v_persona_id INT(11);
	DECLARE v_modif BOOLEAN DEFAULT FALSE; 
	DECLARE v_preorden INT(11);
	DECLARE v_cant_disponible_tot DECIMAL(10,2);
	DECLARE v_pscompra_old DECIMAL(10,2);
	
	/*Muevo la cantidad a la disponible*/
	SET new.nmcantidad_disponible = new.nmcantidad;
	
	/*Actualizar precio de compra y proveedor*/
	SET v_pscompra_old = (SELECT pscompra FROM productos WHERE id = new.producto_id);
	IF new.psvalor_unitario < v_pscompra_old THEN
		SET v_pscompra = new.psvalor_unitario;
		SET v_persona_id := (SELECT persona_id FROM entradas WHERE id = new.entrada_id);
		SET v_modif = TRUE;
	END IF;
	
	/*Eliminar plan de compras del producto*/
	SET v_preorden = (SELECT preorden FROM productos WHERE id = new.producto_id);
	SET v_cant_disponible_tot = (SELECT SUM(nmcantidad_disponible) FROM entradas_productos WHERE producto_id = new.producto_id) + new.nmcantidad_disponible;
	IF v_preorden < v_cant_disponible_tot THEN
		DELETE FROM planes_compras
		WHERE producto_id = new.producto_id;
	END IF;
	
	/*Actualizo la tabla de productos con cantidades y valores
	calculados para el costo promedio*/
	UPDATE productos
	  SET nmcantidad = nmcantidad + new.nmcantidad,
	      nmsuma_total_productos = nmsuma_total_productos + new.nmcantidad,
	      pssuma_total_valores = pssuma_total_valores + 
			( new.nmcantidad * new.psvalor_unitario ),
	      psventa = IF(psventa < 	new.psvalor_unitario * 1.2,
			new.psvalor_unitario * 1.2,
			psventa),
	      pscompra = IF(v_modif = TRUE, v_pscompra, pscompra),
	      persona_id = IF(v_modif = TRUE, v_persona_id, persona_id)
	  WHERE id = new.producto_id;
    END */;;
DELIMITER ;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE */;


# Dump of table personas
# ------------------------------------------------------------

DROP TABLE IF EXISTS `personas`;

CREATE TABLE `personas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) DEFAULT NULL,
  `direccion` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `personas` WRITE;
/*!40000 ALTER TABLE `personas` DISABLE KEYS */;

INSERT INTO `personas` (`id`, `name`, `direccion`)
VALUES
	(3,'Hugo',NULL),
	(4,'Paco',NULL),
	(5,'Luis',NULL);

/*!40000 ALTER TABLE `personas` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table planes_compras
# ------------------------------------------------------------

DROP TABLE IF EXISTS `planes_compras`;

CREATE TABLE `planes_compras` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `producto_id` int(11) NOT NULL,
  `persona_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `producto_idx` (`producto_id`),
  KEY `proveedor_idx` (`persona_id`),
  CONSTRAINT `producto` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `proveedor` FOREIGN KEY (`persona_id`) REFERENCES `personas` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `planes_compras` WRITE;
/*!40000 ALTER TABLE `planes_compras` DISABLE KEYS */;

INSERT INTO `planes_compras` (`id`, `producto_id`, `persona_id`)
VALUES
	(1,5,5);

/*!40000 ALTER TABLE `planes_compras` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table productos
# ------------------------------------------------------------

DROP TABLE IF EXISTS `productos`;

CREATE TABLE `productos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) DEFAULT NULL,
  `nmcantidad` int(11) DEFAULT NULL,
  `pssuma_total_valores` decimal(10,2) DEFAULT NULL,
  `nmsuma_total_productos` int(11) DEFAULT NULL,
  `psventa` decimal(10,2) DEFAULT NULL,
  `preorden` int(11) DEFAULT '10',
  `persona_id` int(11) NOT NULL,
  `pscompra` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `persona_id_idx` (`persona_id`),
  CONSTRAINT `productos_ibfk_1` FOREIGN KEY (`persona_id`) REFERENCES `personas` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `productos` WRITE;
/*!40000 ALTER TABLE `productos` DISABLE KEYS */;

INSERT INTO `productos` (`id`, `name`, `nmcantidad`, `pssuma_total_valores`, `nmsuma_total_productos`, `psventa`, `preorden`, `persona_id`, `pscompra`)
VALUES
	(3,'Vino',50,2550000.00,50,66000.00,10,4,NULL),
	(4,'Queso',50,1200000.00,50,36000.00,10,3,NULL),
	(5,'Aceituna',15,32000.00,40,1200.00,10,5,NULL),
	(6,'Jamon',30,1800000.00,30,72000.00,10,3,NULL);

/*!40000 ALTER TABLE `productos` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table productos_salidas
# ------------------------------------------------------------

DROP TABLE IF EXISTS `productos_salidas`;

CREATE TABLE `productos_salidas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nmcantidad` int(11) DEFAULT NULL,
  `salida_id` int(11) NOT NULL,
  `producto_id` int(11) NOT NULL,
  `psvalor_venta` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_productos_salidas_salidas1_idx` (`salida_id`),
  KEY `fk_productos_salidas_productos1_idx` (`producto_id`),
  CONSTRAINT `fk_productos_salidas_productos1` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_productos_salidas_salidas1` FOREIGN KEY (`salida_id`) REFERENCES `salidas` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `productos_salidas` WRITE;
/*!40000 ALTER TABLE `productos_salidas` DISABLE KEYS */;

INSERT INTO `productos_salidas` (`id`, `nmcantidad`, `salida_id`, `producto_id`, `psvalor_venta`)
VALUES
	(3,25,5,5,1000.00);

/*!40000 ALTER TABLE `productos_salidas` ENABLE KEYS */;
UNLOCK TABLES;

DELIMITER ;;
/*!50003 SET SESSION SQL_MODE="STRICT_TRANS_TABLES,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ALLOW_INVALID_DATES,ERROR_FOR_DIVISION_BY_ZERO,TRADITIONAL,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION" */;;
/*!50003 CREATE */ /*!50017 DEFINER=`root`@`localhost` */ /*!50003 TRIGGER `productos_salidas_bi` BEFORE INSERT ON `productos_salidas` FOR EACH ROW BEGIN
	/*--- var trabajo ---*/
	 declare no_more_rows boolean default false;
	 /*Control productos*/
	 declare v_nmcantidad int;
	 declare v_psventa dec(10,2);
	 /*Control fifo*/
	 declare v_entrada_producto_id int;
	 declare v_feentrada datetime;
	 declare v_nmcantidad_disponible int;
	 DECLARE v_pendiente INT;
	 
	 /*** Agregar plan de compras ***/
	 DECLARE v_nmcantidad_producto INT;
	 DECLARE v_preorden int(11);
	 declare v_insert_plan INT(11);
	 declare v_proveedor_id int(11);
	/*--- cursores ---*/
	 declare cursor1 cursor for
           select entradas_productos.id, nmcantidad_disponible, feentrada
		from entradas_productos, entradas
		where entradas.id = entradas_productos.entrada_id and
			producto_id = new.producto_id and
			nmcantidad_disponible > 0
		order by 3 asc;
	/*--- control ---*/
	declare continue handler for not found 
            set no_more_rows := true;
	/*-------- 1-Validar Inventario ---------*/
	SELECT nmcantidad, psventa
		into v_nmcantidad,v_psventa
		FROM productos
		WHERE id = new.producto_id;
	
	if new.nmcantidad > v_nmcantidad then
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'No hay cantidad suficiente en el inventario';
	end if;
        IF new.psvalor_venta < v_psventa THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Valor venta inferior al permitido';
	END IF;
	/*-------- 2-Restar de Inventario ---------*/
	update productos
		set nmcantidad = nmcantidad - new.nmcantidad
		where id = new.producto_id;
		
		
	/*---- Insertar en tabla de compras-----*/
	
	SET v_nmcantidad_producto = (SELECT nmcantidad from productos where id = new.producto_id);
	SET v_preorden = (select preorden from productos where id = new.producto_id);
	SET v_proveedor_id = (select persona_id from productos where id = new.producto_id);
	if v_nmcantidad_producto < v_preorden then
		SET v_insert_plan = (SELECT COUNT(*) FROM planes_compras WHERE producto_id = new.producto_id group by producto_id);
		
		if v_insert_plan IS NULL then
			insert into planes_compras (producto_id, persona_id) values(new.producto_id, v_proveedor_id);
		elseif (v_proveedor_id <> (SELECT persona_id from planes_compras where id = new.producto_id)) then
			update planes_compras
				set persona_id = v_proveedor_id
				where producto_id = new.producto_id;			
		end if;			
	end if;
	
	/*-------- 3-FIFO ---------*/
	
	
        open cursor1;
	set v_pendiente = new.nmcantidad; /*Todo esta pendiente*/
        LOOP1: loop
            fetch cursor1 into v_entrada_producto_id,v_nmcantidad_disponible,v_feentrada;
            if no_more_rows then
                close cursor1;
                leave LOOP1;
            end if;
        if v_pendiente > v_nmcantidad_disponible then
		/*Queda pendientes*/
		set v_pendiente = v_pendiente - v_nmcantidad_disponible;
		update entradas_productos
			set nmcantidad_disponible = 0
			where id = v_entrada_producto_id;
        else
		UPDATE entradas_productos
			SET nmcantidad_disponible = nmcantidad_disponible - v_pendiente
			WHERE id = v_entrada_producto_id;
		
		CLOSE cursor1;
                LEAVE LOOP1;	
        end if;        
        end loop LOOP1;	 
    END */;;
DELIMITER ;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE */;


# Dump of table salidas
# ------------------------------------------------------------

DROP TABLE IF EXISTS `salidas`;

CREATE TABLE `salidas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fesalida` datetime DEFAULT NULL,
  `persona_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_salidas_clientes1_idx` (`persona_id`),
  CONSTRAINT `fk_salidas_clientes1` FOREIGN KEY (`persona_id`) REFERENCES `personas` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `salidas` WRITE;
/*!40000 ALTER TABLE `salidas` DISABLE KEYS */;

INSERT INTO `salidas` (`id`, `fesalida`, `persona_id`)
VALUES
	(5,'2016-03-23 00:00:00',3);

/*!40000 ALTER TABLE `salidas` ENABLE KEYS */;
UNLOCK TABLES;



/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
