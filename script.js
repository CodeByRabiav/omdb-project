const API_KEY = "7449046c";
const searchBtn = document.getElementById('searchBtn');
const movieInput = document.getElementById('movieInput');
const resultDiv = document.getElementById('result');

window.onload = () => {
    const lastSearch = localStorage.getItem('lastMovie');
    if (lastSearch) {
        movieInput.value = lastSearch;
        getMovieData(lastSearch);
    }
};

searchBtn.addEventListener('click', () => {
    const movieName = movieInput.value.trim();
    if (movieName) {
        getMovieData(movieName);
    }
});

async function getMovieData(title) {
    resultDiv.innerHTML = `<p>Loading...</p>`;
    
    try {
        
        const searchResponse = await fetch(`https://www.omdbapi.com/?s=${encodeURIComponent(title)}&apikey=${API_KEY}`);
        const searchData = await searchResponse.json();

        if (searchData.Response === "True") {
            
            const firstMovieId = searchData.Search[0].imdbID;

            
            const detailResponse = await fetch(`https://www.omdbapi.com/?i=${firstMovieId}&apikey=${API_KEY}`);
            const fullDetails = await detailResponse.json();

            displayMovie(fullDetails);
            localStorage.setItem('lastMovie', title);
        } else {
            resultDiv.innerHTML = `<p class="error-msg">Error: ${searchData.Error}</p>`;
        }
    } catch (error) {
        resultDiv.innerHTML = `<p class="error-msg">A connection error has occurred!</p>`;
    }
}

function displayMovie(movie) {
    
    const poster = movie.Poster !== 'N/A' ? movie.Poster : 'https://via.placeholder.com/300x450?text=Afiş+Yok';
    
    resultDiv.innerHTML = `
        <div class="movie-card">
            <img src="${poster}" alt="${movie.Title}">
            <div class="movie-info">
                <h2>${movie.Title} (${movie.Year})</h2>
                <p><strong>Director:</strong> ${movie.Director !== 'N/A' ? movie.Director : 'No information available'}</p>
                <p><strong>Type:</strong> ${movie.Genre !== 'N/A' ? movie.Genre : 'No information available'}</p>
                <p><strong>IMDb Rating:</strong> ⭐ ${movie.imdbRating !== 'N/A' ? movie.imdbRating : 'No points'}</p>
                <p><strong>Summary:</strong> ${movie.Plot !== 'N/A' ? movie.Plot : 'No summary found.'}</p>
            </div>
        </div>
    `;
}


movieInput.addEventListener('keypress', (e) => {
    if (e.key === 'Enter') searchBtn.click();
});
