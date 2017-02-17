-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

-- -----------------------------------------------------
-- Schema Udem_Inventario
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema Udem_Inventario
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `Udem_Inventario` DEFAULT CHARACTER SET utf8 ;
USE `Udem_Inventario` ;

-- -----------------------------------------------------
-- Table `Udem_Inventario`.`productos`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Udem_Inventario`.`productos` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NULL,
  `nmcantidad_disponible` INT NULL,
  `nmsuma_cantidad_total` INT NULL,
  `nmsuma_valor_total` DECIMAL(10,2) NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Udem_Inventario`.`personas`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Udem_Inventario`.`personas` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NULL,
  `direccion` VARCHAR(45) NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Udem_Inventario`.`entradas`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Udem_Inventario`.`entradas` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `feentrada` DATETIME NULL,
  `persona_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_entradas_clientes_idx` (`persona_id` ASC),
  CONSTRAINT `fk_entradas_clientes`
    FOREIGN KEY (`persona_id`)
    REFERENCES `Udem_Inventario`.`personas` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Udem_Inventario`.`salidas`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Udem_Inventario`.`salidas` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `fesalida` DATETIME NULL,
  `persona_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_salidas_clientes1_idx` (`persona_id` ASC),
  CONSTRAINT `fk_salidas_clientes1`
    FOREIGN KEY (`persona_id`)
    REFERENCES `Udem_Inventario`.`personas` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Udem_Inventario`.`entradas_productos`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Udem_Inventario`.`entradas_productos` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `nmcantidad` INT NULL,
  `entrada_id` INT NOT NULL,
  `producto_id` INT NOT NULL,
  `nmcantidad_disponible` INT NULL,
  `nmvalor_unitario` DECIMAL(10,2) NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_entradas_productos_entradas1_idx` (`entrada_id` ASC),
  INDEX `fk_entradas_productos_productos1_idx` (`producto_id` ASC),
  CONSTRAINT `fk_entradas_productos_entradas1`
    FOREIGN KEY (`entrada_id`)
    REFERENCES `Udem_Inventario`.`entradas` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_entradas_productos_productos1`
    FOREIGN KEY (`producto_id`)
    REFERENCES `Udem_Inventario`.`productos` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Udem_Inventario`.`productos_salidas`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Udem_Inventario`.`productos_salidas` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `nmcantidad` INT NULL,
  `salida_id` INT NOT NULL,
  `producto_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_productos_salidas_salidas1_idx` (`salida_id` ASC),
  INDEX `fk_productos_salidas_productos1_idx` (`producto_id` ASC),
  CONSTRAINT `fk_productos_salidas_salidas1`
    FOREIGN KEY (`salida_id`)
    REFERENCES `Udem_Inventario`.`salidas` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_productos_salidas_productos1`
    FOREIGN KEY (`producto_id`)
    REFERENCES `Udem_Inventario`.`productos` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
