-- Web3 Data Analytics SQL Queries
-- This script extracts blockchain transaction data, NFT trades, and DeFi participation metrics.

-- Total Transaction Value in the Last 30 Days (ETH & USD Conversion)
WITH raw_data AS (
    SELECT 
        usd_amount / eth_price AS eth_amount, 
        date_trunc('minute', block_time) AS block_time, 
        tx_hash, 
        nft_token_id
    FROM nft_trades
    LEFT JOIN (
        SELECT minute, price AS eth_price
        FROM prices_usd
        WHERE symbol = 'ETH'
    ) AS prices ON date_trunc('minute', block_time) = minute
)
SELECT SUM(eth_amount) AS total_transaction_value_eth,
       SUM(usd_amount) AS total_transaction_value_usd
FROM raw_data
WHERE block_time >= NOW() - INTERVAL '30 days';

-- Count of Active Addresses in the Last 7 Days
SELECT COUNT(DISTINCT address) AS active_addresses
FROM addresses
WHERE last_active_date >= NOW() - INTERVAL '7 days';

-- Most Interacted Smart Contracts
SELECT contract_address, COUNT(*) AS interaction_count
FROM smart_contract_interactions
GROUP BY contract_address
ORDER BY interaction_count DESC
LIMIT 5;

-- Top Users by dApp Interactions
SELECT contract_address, COUNT(*) AS interaction_count
FROM smart_contract_interactions
GROUP BY contract_address
ORDER BY interaction_count DESC
LIMIT 5;

-- Highest NFT Sale in the Last 6 Months (ETH & USD)
WITH raw_data AS (
    SELECT 
        token_id, 
        owner_address, 
        marketplace, 
        last_sale_price / eth_price AS last_sale_price_eth, 
        last_sale_price AS last_sale_price_usd
    FROM nft_sales
    LEFT JOIN (
        SELECT minute, price AS eth_price
        FROM prices_usd
        WHERE symbol = 'ETH'
    ) AS prices ON date_trunc('minute', last_sale_date) = minute
)
SELECT token_id, owner_address, marketplace, last_sale_price_eth, last_sale_price_usd
FROM raw_data
WHERE last_sale_date >= NOW() - INTERVAL '6 months'
ORDER BY last_sale_price_usd DESC
LIMIT 1;

-- Total DeFi Participation in the Last Year
SELECT platform, SUM(participation_amount) AS total_participation
FROM defi_participation
WHERE participation_date >= NOW() - INTERVAL '1 year'
GROUP BY platform
ORDER BY total_participation DESC;











