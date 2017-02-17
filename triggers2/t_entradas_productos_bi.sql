BEGIN
	/*Muevo la cantidad a la disponible*/
	set new.nmcantidad_disponible = new.nmcantidad;
	/*Actualizo la tabla de productos con cantidades y valores
	calculados para el costo promedio*/
  DECLARE v_pscompra DECIMAL(10,2);
  DECLARE v_persona_id INT(11);
  DECLARE v_modif BOOLEAN DEFAULT FALSE;
  DECLARE v_preorden INT(11);
  DECLARE v_cant_disponible_tot DECIMAL(10,2);
  DECLARE v_pscompra_old DECIMAL(10,2);


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

	update productos
  set nmcantidad = nmcantidad + new.nmcantidad,
      nmsuma_total_productos = nmsuma_total_productos + new.nmcantidad,
      pssuma_total_valores = pssuma_total_valores +
		( new.nmcantidad * new.psvalor_unitario ),
      psventa = if(psventa < 	new.psvalor_unitario * 1.2,
		new.psvalor_unitario * 1.2,
		psventa),
      pscompra = IF(v_modif = TRUE, v_pscompra, pscompra),
      persona_id = IF(v_modif = TRUE, v_persona_id, persona_id)
  where id = new.producto_id;

END
