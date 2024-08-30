// Header.js

import React, { useState, useEffect } from 'react';

const Header = () => {
  const [account, setAccount] = useState(null);

  const connectWallet = async () => {
    if (window.ethereum) {
      try {
        // Request account access if needed
        const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
        // Get the first account
        setAccount(accounts[0]);
      } catch (error) {
        console.error("Error connecting to MetaMask:", error);
      }
    } else {
      alert("MetaMask not detected. Please install MetaMask to use this dApp.");
    }
  };

  useEffect(() => {
    if (account) {
      console.log("Connected account:", account);
    }
  }, [account]);

  return (
    <header style={styles.header}>
      <h1 style={styles.title}>My dApp</h1>
      <button onClick={connectWallet} style={styles.button}>
        {account ? `${account.slice(0, 6)}...${account.slice(-4)}` : "Connect Wallet"}
      </button>
    </header>
  );
};

const styles = {
  header: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: '10px 20px',
    backgroundColor: '#282c34',
    color: 'white',
  },
  title: {
    margin: 0,
  },
  button: {
    padding: '10px 20px',
    backgroundColor: '#61dafb',
    color: '#282c34',
    border: 'none',
    borderRadius: '5px',
    cursor: 'pointer',
    fontSize: '16px',
  },
};

export default Header;
