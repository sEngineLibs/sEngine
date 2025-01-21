package s2d.core.utils.extensions;

import haxe.ds.Vector;

class VectorExt {
	/**
	 * Adds the element x at the end of a vector. This operation does not modify a.
	 * @param a The Vector to which the element will be added
	 * @param x The element to be added
	 * @return Returns a new Vector with the added element
	 */
	public static inline function push<T>(a:Vector<T>, x:T):Vector<T> {
		final v = new Vector<T>(a.length + 1); // Создаём новый вектор большего размера
		Vector.blit(a, 0, v, 0, a.length); // Копируем элементы из старого вектора
		v[a.length] = x; // Добавляем новый элемент
		return v;
	}

	/**
	 * Appends the elements of b to the elements of a. This operation does not modify a or b.
	 * @param a The Vector to which elements of b will be appended
	 * @param b The Vector whose elements will be appended
	 * @return Returns a new Vector containing elements of a and b
	 */
	public static inline function concat<T>(a:Vector<T>, b:Vector<T>):Vector<T> {
		final v = new Vector<T>(a.length + b.length); // Создаём новый вектор суммарного размера
		Vector.blit(a, 0, v, 0, a.length); // Копируем элементы из a
		Vector.blit(b, 0, v, a.length, b.length); // Копируем элементы из b
		return v;
	}
}
