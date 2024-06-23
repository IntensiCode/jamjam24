// before you start laughing: this code is based on j2me code from 200x. j2me
// devices were quite limited back in the days... :-D

import 'dart:math';

class MathExtended {
  MathExtended._();

  static double length(double aX, double aY) => sqrt(aX * aX + aY * aY);
}

// public class MathExtended
//     {
//     public final static float PI2f = (float) ( Math.PI * 2 );
//
//     public final static double PI2d = Math.PI * 2;
//
//     public static final float TO_RADIANSf = (float) ( Math.PI / 180 );
//
//     public static final double TO_RADIANSd = Math.PI / 180;
//
//     public final static double SQRT3 = 1.732050807568877294;
//
//     public final static double LOGdiv2 = -0.6931471805599453094;
//
//
//     public static float toDegrees( final float aRadians )
//         {
//         return aRadians / TO_RADIANSf;
//         }
//
//     public static double toDegrees( final double aRadians )
//         {
//         return aRadians / TO_RADIANSd;
//         }
//
//     public static float toRadians( final float aDegrees )
//         {
//         return aDegrees * TO_RADIANSf;
//         }
//
//     public static double toRadians( final double aDegrees )
//         {
//         return aDegrees * TO_RADIANSd;
//         }
//
//     public static float fraction( final float aValue )
//         {
//         return aValue - (int) aValue;
//         }
//
//     public static int round( final float aValue )
//         {
//         if ( aValue > 0 ) return (int) ( aValue + 0.5f );
//         if ( aValue < 0 ) return (int) ( aValue - 0.5f );
//         return 0;
//         }
//
//     public static int round( final double aValue )
//         {
//         if ( aValue > 0 ) return (int) ( aValue + 0.5 );
//         if ( aValue < 0 ) return (int) ( aValue - 0.5 );
//         return 0;
//         }

//     public static double length( final double aX, final double aY )
//         {
//         return Math.sqrt( aX * aX + aY * aY );
//         }
//
//     public static float sin( final float value )
//         {
//         return (float) Math.sin( value );
//         }
//
//     public static double sin( final double value )
//         {
//         return Math.sin( value );
//         }
//
//     public static float cos( final float value )
//         {
//         return (float) Math.cos( value );
//         }
//
//     public static double cos( final double value )
//         {
//         return Math.cos( value );
//         }
//
//     public static double asin( final double value )
//         {
//         if ( value < -1.0 || value > 1.0 ) return Double.NaN;
//         if ( value == -1.0 ) return PI_HALF_MINUS;
//         if ( value == 1 ) return PI_HALF;
//         return atan( value / Math.sqrt( 1 - value * value ) );
//         }
//
//     public static double acos( final double value )
//         {
//         final double f = asin( value );
//         if ( f == Double.NaN ) return f;
//         return PI_HALF - f;
//         }
//
//     public static double atan( double value )
//         {
//         boolean signChange = false;
//         boolean Invert = false;
//         int sp = 0;
//         final double x2;
//         double a;
//
//         if ( value < 0.0 )
//             {
//             value = -value;
//             signChange = true;
//             }
//
//         if ( value > 1.0 )
//             {
//             value = 1 / value;
//             Invert = true;
//             }
//
//         while ( value > PI_BY_12 )
//             {
//             sp++;
//             a = value + SQRT3;
//             a = 1 / a;
//             value = value * SQRT3;
//             value = value - 1;
//             value = value * a;
//             }
//
//         x2 = value * value;
//         a = x2 + 1.4087812;
//         a = 0.55913709 / a;
//         a = a + 0.60310579;
//         a = a - ( x2 * 0.05160454 );
//         a = a * value;
//
//         while ( sp > 0 )
//             {
//             a = a + PI_BY_6;
//             sp--;
//             }
//
//         if ( Invert ) a = PI_HALF - a;
//         if ( signChange ) a = -a;
//
//         return a;
//         }
//
//     public static double atan2( final double y, final double x )
//         {
//         if ( y == 0. && x == 0.0 ) return 0.;
//         if ( x > 0.0 ) return atan( y / x );
//
//         if ( x < 0.0 )
//             {
//             if ( y < 0.0 ) return -( Math.PI - atan( y / x ) );
//             else return Math.PI - atan( -y / x );
//             }
//
//         if ( y < 0.0 ) return PI_HALF_MINUS;
//         else return PI_HALF;
//         }
//
//     public static double log( double value )
//         {
//         if ( !( value > 0.0 ) ) return Double.NaN;
//         if ( value == 1.0 ) return 0.0;
//
//         // Argument of _log must be (0; 1]
//         if ( value > 1.0 )
//             {
//             value = 1 / value;
//             return -_log( value );
//             }
//
//         return _log( value );
//         }
//
//     public static double exp( double value )
//         {
//         if ( value == 0.0 ) return 1.;
//
//         double f = 1;
//         final long d = 1;
//         double k;
//         final boolean isless = ( value < 0.0 );
//         if ( isless ) value = -value;
//         k = value / d;
//
//         for ( long i = 2; i < 50; i++ )
//             {
//             f = f + k;
//             k = k * value / i;
//             }
//
//         if ( isless ) return 1 / f;
//         else return f;
//         }
//
//     // Implementation
//
//     private static double _log( double value )
//         {
//         if ( !( value > 0.0 ) ) return Double.NaN;
//
//         double f = 0.0;
//
//         int appendix = 0;
//         while ( value > 0.0 && value <= 1.0 )
//             {
//             value *= 2.0;
//             appendix++;
//             }
//
//         value /= 2.0;
//         appendix--;
//
//         final double y1 = value - 1.0;
//         double y2 = value + 1.0;
//         final double y = y1 / y2;
//
//         double k = y;
//         y2 = k * y;
//
//         for ( long i = 1; i < 50; i += 2 )
//             {
//             f += k / i;
//             k *= y2;
//             }
//
//         f *= 2.0;
//         for ( int i = 0; i < appendix; i++ )
//             {
//             f += LOGdiv2;
//             }
//
//         return f;
//         }
//
//     public static double pow( final double x, final double y )
//         {
//         if ( y == 0.0 ) return 1.0;
//         if ( y == 1.0 ) return x;
//         if ( x == 0.0 ) return 0.0;
//         if ( x == 1.0 ) return 1.0;
//
//         final long l = (long) Math.floor( y );
//         final boolean integerValue = ( y == (double) l );
//
//         if ( integerValue )
//             {
//             boolean neg = false;
//             if ( y < 0.0 ) neg = true;
//
//             double result = x;
//             for ( long i = 1; i < ( neg ? -l : l ); i++ )
//                 {
//                 result = result * x;
//                 }
//
//             if ( neg ) return 1.0 / result;
//             else return result;
//             }
//         else
//             {
//             if ( x > 0.0 ) return exp( y * log( x ) );
//             else return Double.NaN;
//             }
//         }
//
//     private static final double PI_HALF = Math.PI / 2.;
//
//     private static final double PI_HALF_MINUS = -Math.PI / 2.;
//
//     private static final double PI_BY_6 = Math.PI / 6;
//
//     private static final double PI_BY_12 = Math.PI / 12;
//     }
