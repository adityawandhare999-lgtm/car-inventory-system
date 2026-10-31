-- Index for faster searching of inventory by status
CREATE INDEX idx_cars_status ON cars(status);
CREATE INDEX idx_cars_model  ON cars(model_id);

-- View: all cars currently available for sale
CREATE VIEW v_available_inventory AS
SELECT c.car_id, m.name AS manufacturer, cm.model_name, cm.fuel_type,
       c.color, c.manufacture_year, c.car_condition, c.selling_price
FROM cars c
JOIN car_models   cm ON cm.model_id = c.model_id
JOIN manufacturers m ON m.manufacturer_id = cm.manufacturer_id
WHERE c.status = 'Available';

-- Trigger: validate a sale and automatically mark the car as Sold
CREATE OR REPLACE FUNCTION fn_mark_car_sold() RETURNS TRIGGER AS $$
DECLARE cur_status VARCHAR;
BEGIN
    SELECT status INTO cur_status FROM cars WHERE car_id = NEW.car_id;
    IF cur_status IN ('Sold','In Service') THEN
        RAISE EXCEPTION 'Car % cannot be sold: current status is %', NEW.car_id, cur_status;
    END IF;
    UPDATE cars SET status = 'Sold' WHERE car_id = NEW.car_id;
    RETURN NEW;
END; $$ LANGUAGE plpgsql;

CREATE TRIGGER trg_mark_car_sold
BEFORE INSERT ON sales
FOR EACH ROW EXECUTE FUNCTION fn_mark_car_sold();
