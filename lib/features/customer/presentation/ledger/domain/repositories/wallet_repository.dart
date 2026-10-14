import '../entities/wallet.dart';

abstract class WalletRepository {
  Stream<Wallet> watchWallet(String userId);
  Future<Wallet?> getWallet(String userId);
}
