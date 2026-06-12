import { describe, it, expect } from 'vitest';
import { add, subtract, multiply, divide } from './example';

describe('Math operations', () => {
  describe('add', () => {
    it('returns the correct result when adding positive numbers', () => {
      // Given: setup
      const a = 2;
      const b = 3;

      // When: execute
      const result = add(a, b);

      // Then: verify
      expect(result).toBe(5);
    });

    it('returns the correct result when adding a negative number', () => {
      // Given: setup
      const a = -2;
      const b = 3;

      // When: execute
      const result = add(a, b);

      // Then: verify
      expect(result).toBe(1);
    });
  });

  describe('subtract', () => {
    it('returns the correct result when subtracting positive numbers', () => {
      // Given: setup
      const a = 5;
      const b = 3;

      // When: execute
      const result = subtract(a, b);

      // Then: verify
      expect(result).toBe(2);
    });
  });

  describe('multiply', () => {
    it('returns the correct result when multiplying positive numbers', () => {
      // Given: setup
      const a = 2;
      const b = 3;

      // When: execute
      const result = multiply(a, b);

      // Then: verify
      expect(result).toBe(6);
    });

    it('returns 0 when multiplying by 0', () => {
      // Given: setup
      const a = 5;
      const b = 0;

      // When: execute
      const result = multiply(a, b);

      // Then: verify
      expect(result).toBe(0);
    });
  });

  describe('divide', () => {
    it('returns the correct result when dividing by a positive number', () => {
      // Given: setup
      const a = 6;
      const b = 3;

      // When: execute
      const result = divide(a, b);

      // Then: verify
      expect(result).toBe(2);
    });

    it('throws an error when dividing by zero', () => {
      // Given: setup
      const a = 5;
      const b = 0;

      // When/Then: execute and verify
      expect(() => divide(a, b)).toThrow('Division by zero is not allowed');
    });
  });
});
