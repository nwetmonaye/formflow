import { onRequest } from "firebase-functions/v2/https";

export const testFunction = onRequest(
    { maxInstances: 1 },
    (req, res) => {
        res.json({ message: "Test function working!" });
    }
);
