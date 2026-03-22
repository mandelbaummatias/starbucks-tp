-- ============================================================
-- STEP 1: CREATE DATABASE
-- Run this script while connected to 'postgres' (the master DB).
-- DO NOT run this inside a transaction.
-- ============================================================

-- If you are using psql, you can run:
-- psql -U postgres -d postgres -f 01_SETUP_DATABASE.sql

DROP DATABASE IF EXISTS starbucks_dw_raw;
CREATE DATABASE starbucks_dw_raw;

-- Once created, you should connect to starbucks_dw_raw 
-- and then run the 'setup_starbucks.sql' script.
