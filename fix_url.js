const fs = require('fs');
const files = [
  'src/pages/Admin/EventManagement.jsx',
  'src/pages/Admin/ProofApproval.jsx'
];
files.forEach(file => {
  let content = fs.readFileSync(file, 'utf8');
  content = content.replace(/`https:\/\/doan3-ooha\.onrender\.com\$\{([^}]+)\}`/g, "($1 && $1.startsWith('http') ? $1 : `https://doan3-ooha.onrender.com${$1}`)");
  fs.writeFileSync(file, content);
  console.log('Fixed', file);
});
