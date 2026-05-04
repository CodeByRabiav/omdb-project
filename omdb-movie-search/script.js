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
            resultDiv.innerHTML = `<p class="error-msg">Hata: ${searchData.Error}</p>`;
        }
    } catch (error) {
        resultDiv.innerHTML = `<p class="error-msg">Bağlantı hatası oluştu!</p>`;
    }
}

function displayMovie(movie) {
    
    const poster = movie.Poster !== 'N/A' ? movie.Poster : 'https://via.placeholder.com/300x450?text=Afiş+Yok';
    
    resultDiv.innerHTML = `
        <div class="movie-card">
            <img src="${poster}" alt="${movie.Title}">
            <div class="movie-info">
                <h2>${movie.Title} (${movie.Year})</h2>
                <p><strong>Yönetmen:</strong> ${movie.Director !== 'N/A' ? movie.Director : 'Bilgi Yok'}</p>
                <p><strong>Tür:</strong> ${movie.Genre !== 'N/A' ? movie.Genre : 'Bilgi Yok'}</p>
                <p><strong>IMDb Puanı:</strong> ⭐ ${movie.imdbRating !== 'N/A' ? movie.imdbRating : 'Puan Yok'}</p>
                <p><strong>Özet:</strong> ${movie.Plot !== 'N/A' ? movie.Plot : 'Özet bulunamadı.'}</p>
            </div>
        </div>
    `;
}


movieInput.addEventListener('keypress', (e) => {
    if (e.key === 'Enter') searchBtn.click();
});