import productData from '../../../mock/product.json';
import { User, Product, GlobalStore } from '../model/Models';
import { UserPersistence } from './UserPersistence';

/** 应用启动时加载商品与用户数据（用户数据优先读沙箱 user_data.json） */
export function initAppData(): void {
  if (!GlobalStore.productsLoaded) {
    GlobalStore.allProducts = (productData as Record<string, Object>)['data'] as Product[];
    GlobalStore.productsLoaded = true;
  }
  if (!GlobalStore.usersLoaded) {
    GlobalStore.initUsers(UserPersistence.loadUsers() as User[]);
  }
}

/** Preview 或未走 EntryAbility 时保证数据已加载 */
export function ensureAppData(): void {
  if (!GlobalStore.productsLoaded || !GlobalStore.usersLoaded) {
    initAppData();
  }
}
