USE `udem_inventario`$$

DROP TRIGGER /*!50032 IF EXISTS */ `t_entradas_productos_bi`$$

CREATE
    TRIGGER `t_entradas_productos_bi` AFTER INSERT ON `entradas_productos`
    FOR EACH ROW BEGIN
      DECLARE precio DECIMAL(10,2);
      SET precio = (SELECT AVG(nmvalor_unitario)
              FROM entradas_productos
              WHERE producto_id = new.producto_id);
      UPDATE productos
      SET precio_venta = precio + (precio * 0.2)
      WHERE id = new.producto_id;
    END$$

DELIMITER ;
