import React from 'react';
import ReactDOM from 'react-dom';
import './index.css';
import App from './App';

async function main() {
  ReactDOM.render(
    <React.StrictMode>
          <App />
    </React.StrictMode>,
    document.getElementById('root')
  );
}

main().catch((err) => {
  console.error("Failed to initialize Apollo Client:", err);
});
