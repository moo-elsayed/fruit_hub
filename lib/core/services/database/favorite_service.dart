abstract class FavoriteService {
  Future<void> toggleFavorite(String productId);

  bool isFavorite(String productId);
}
