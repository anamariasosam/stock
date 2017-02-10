SELECT E.feentrada, EP.id, EP.nmcantidad_disponible, EP.nmcantidad
FROM entradas E, entradas_productos EP
WHERE
  E.id = EP.entrada_id
  AND
  EP.producto_id = 2
  AND
  EP.nmcantidad_disponible > 0
ORDER BY 1 ASC;
