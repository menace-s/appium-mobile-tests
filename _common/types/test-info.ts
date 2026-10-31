// "Cartouche" d'info affichée dans les logs avant l'exécution d'un test.

export interface TestInfo {
    /** identifiant court du cas de test, ex: "TC-02" */
    id: string;
    /** référence métier / ticket, ex: "CART-ADD-001" */
    reference: string;
    /** titre lisible du cas de test */
    title: string;
    /** description optionnelle, 1 ligne */
    description?: string;
}
