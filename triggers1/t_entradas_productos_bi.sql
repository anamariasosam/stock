DELIMITER $$

USE `udem_inventario`$$

DROP TRIGGER /*!50032 IF EXISTS */ `t_entradas_productos_bi`$$

CREATE
    TRIGGER `t_entradas_productos_bi` BEFORE INSERT ON `entradas_productos`
    FOR EACH ROW BEGIN
      SET new.nmcantidad_disponible = new.nmcantidad;

      UPDATE productos
      SET
      nmcantidad_disponible = nmcantidad_disponible + new.nmcantidad,
      nmsuma_cantidad_total = nmsuma_cantidad_total + new.nmcantidad,
      nmsuma_valor_total = nmsuma_valor_total + (new.nmcantidad * new.nmvalor_unitario)
      WHERE id = new.producto_id;

    END$$

DELIMITER ;
