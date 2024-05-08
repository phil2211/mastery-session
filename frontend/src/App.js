import React, { useState } from 'react';
import { Tooltip, Grid, Card, CardMedia, CardContent, Typography, Button, TextField } from '@mui/material';
import defaultPoster from './assets/na.jpeg';

const LAMBDA_URL = 'https://scb6pwpgt5rexcvjd4vpm6yyc40sznrf.lambda-url.eu-central-1.on.aws/';

function App() {
  const [searchText, setSearchText] = useState('');
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const handleSearch = async () => {
    setLoading(true);
    setError(null);
    setData(null);

    try {
      const response = await fetch(LAMBDA_URL, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ searchText }),
      });

      if (!response.ok) {
        throw new Error(`Server error: ${response.statusText}`);
      }

      const result = await response.json();
      setData(result);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  if (loading) return <p>Loading...</p>;
  if (error) return <p>Error: {error}</p>;

  return (
    <div>
      <Grid container spacing={2} style={{ padding: '20px', marginBottom: '20px' }}>
        <Grid item xs={10} sm={11}>
          <TextField 
            label="Search" 
            variant="outlined" 
            fullWidth
            value={searchText} 
            onChange={(e) => setSearchText(e.target.value)}
            style={{ marginRight: '10px' }}
            InputProps={{
              style: { fontSize: '2rem' } // Adjust font size here
            }}
          />
        </Grid>
        <Grid item xs={2} sm={1}>
          <Button 
            variant="contained" 
            onClick={handleSearch}
            fullWidth
            sx={{ height: '100%' }}
            >Search
          </Button>
        </Grid>
      </Grid>
      <Grid container spacing={2} justifyContent="center" style={{ padding: 50 }}>
        {data?.rows.map((item, index) => (
          <Grid item xs={12} sm={6} md={4} lg={3} xl={2.4} key={index}>
            <Card key={index} sx={{ maxWidth: 345 }}>
              <CardMedia
                component="img"
                height="450"
                image={item.poster || defaultPoster}
                alt={item.title}
              />
              <CardContent>
                <Typography gutterBottom variant="h5" component="div">
                  {item.title} ({item.year})
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  {item.plot}
                </Typography>
              </CardContent>
              <Tooltip title={<span style={{ fontSize: "2em" }}>{item.fullplot || "No detailed plot available"}</span>}>
                <Button size="small">See More</Button>
              </Tooltip>
            </Card>
          </Grid>
        ))}
      </Grid>
    </div>
  );
}

export default App;
