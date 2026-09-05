
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

extension Dictionary {

    struct Matrix3D: Equatable where Value: Equatable {

        private var data: [
            String: [
                String: [
                    String: Value
                ]
            ]
        ] = [:]

        public subscript(
            _ x: String,
            _ y: String
        ) -> [String: Value]? {
            get { self.data[x]?[y] }
            set { self.data[x, default: [:]][y] = newValue }
        }

        public subscript(
            _ x: String,
            _ y: String,
            _ z: String
        ) -> Value? {
            get { self.data[x]?[y]?[z] }
            set { self.data[x, default: [:]][y, default: [:]][z] = newValue }
        }

        public subscript(
            _ x: String,
            _ y: String,
            _ z: String,
            default value: Value
        ) -> Value {
            get { self.data[x]?[y]?[z] ?? value }
            set { self.data[x, default: [:]][y, default: [:]][z] = newValue }
        }

    }

}
