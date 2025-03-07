const express = require('express');
const cors = require('cors');
const axios = require('axios');

const app = express();
app.use(cors());
app.use(express.json());

app.get('/books', async (req, res) => {
    try {
        const response = await axios.get('https://www.googleapis.com/books/v1/volumes?q=$searchTerm&maxResults=40');
        console.log(response)
        res.json(response.data);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching data' });
    }
});

app.listen(5000, () => console.log('Server running on port 5000'));
