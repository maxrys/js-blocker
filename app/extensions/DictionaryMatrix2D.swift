
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

extension Dictionary {

    struct Matrix2D {

        private var data: [
            String: [
                String: Value
            ]
        ] = [:]

        public subscript(_ x: String) -> [String: Value]? {
            get { self.data[x] }
            set { self.data[x] = newValue }
        }

        public subscript(
            _ x: String,
            _ y: String
        ) -> Value? {
            get { self.data[x]?[y] }
            set { self.data[x, default: [:]][y] = newValue }
        }

        public subscript(
            _ x: String,
            _ y: String,
            default value: Value
        ) -> Value {
            get { self.data[x]?[y] ?? value }
            set { self.data[x, default: [:]][y] = newValue }
        }

    }

}
