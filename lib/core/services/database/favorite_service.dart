abstract class FavoriteService {
  Future<void> addItemToFavorites(String productId);

  Future<void> removeItemFromFavorites(String productId);
}
