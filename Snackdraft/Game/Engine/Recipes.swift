import Foundation

struct DishRecipe: Identifiable, Equatable, Sendable {
    var id: String
    var name: String
    var subtitle: String
    var world: WorldID
    var required: [SnackID]
    var bonus: Int
    var assetName: String?
    var blurb: String
    var method: String

    var ingredients: [SnackID] { required }

    func matches(_ board: Board) -> Bool {
        let needed = Set(required)
        guard needed.count == required.count else { return false }
        return needed.isSubset(of: connectedIngredients(on: board))
    }

    /// The largest group connected through this recipe's own ingredients.
    /// A diagonal or an unrelated snack cannot bridge two recipe pieces.
    func connectedIngredients(on board: Board) -> Set<SnackID> {
        let needed = Set(required)
        var remaining = Set(board.placed().filter { needed.contains($0.1) }.map(\.0))
        var best: Set<SnackID> = []
        while let start = remaining.min(by: { $0.index < $1.index }) {
            var stack = [start]
            var component: Set<Cell> = []
            remaining.remove(start)
            while let current = stack.popLast() {
                component.insert(current)
                for neighbor in current.neighbors where remaining.contains(neighbor) {
                    remaining.remove(neighbor)
                    stack.append(neighbor)
                }
            }
            let types = Set(component.compactMap { board[$0] })
            if types.count > best.count { best = types }
        }
        return best
    }
}

enum RecipeBook {
    static let all: [DishRecipe] = tea + bento + thai + israeli + italian + garden + kitchen + mexican + indian

    static func recipes(for world: WorldID) -> [DishRecipe] {
        all.filter { $0.world == world }
    }

    static func match(board: Board, world: WorldID) -> DishRecipe? {
        matches(board: board, world: world).first
    }

    static func matches(board: Board, world: WorldID) -> [DishRecipe] {
        recipes(for: world).filter { $0.matches(board) }.sorted(by: { lhs, rhs in
            if lhs.required.count != rhs.required.count {
                return lhs.required.count > rhs.required.count
            }
            return lhs.bonus > rhs.bonus
        })
    }

    static func suggested(for level: LevelDef) -> DishRecipe? {
        let possible = recipes(for: level.world).filter { recipe in
            recipe.required.allSatisfy(level.pool.contains)
        }
        guard !possible.isEmpty else { return nil }
        return possible[level.index % possible.count]
    }

    static func hook(for world: WorldID) -> String {
        switch world {
        case .tea: "Tea beside a cookie is Afternoon Tea. Strawberry on a pancake is Ichigo Hotcake."
        case .bento: "Onigiri wants a neighbor: salmon, shrimp, tamagoyaki, or a soy-sauce glaze."
        case .thai: "Lime wakes up shrimp. Ginger brings fragrance; coconut makes the cluster rich."
        case .israeli: "Start with hummus and pita, then add cool yogurt or briny olives."
        case .italian: "Pasta wants tomato, garlic, or mushroom. Olives finish the shared plate."
        case .garden: "Blueberries on a pancake, or avocado against tomato."
        case .kitchen: "Bacon next to tamagoyaki is a rainy breakfast."
        case .mexican: "Tortilla anchors the plate. Corn adds crunch; beans, lime, and chili shape it."
        case .indian: "Start with curry and naan, then balance ginger heat with yogurt or mango."
        }
    }

    private static let tea: [DishRecipe] = [
        dish("afternoon-tea", "Afternoon Tea", "紅茶とビスケット", .tea,
             [.tea, .cookie], 900, "DishAfternoonTea",
             "A cup of black tea with a chocolate biscuit. The English pause that still works in a Japanese tearoom.",
             "Stand the tea next to a cookie. That is the whole ceremony."),
        dish("ichigo-hotcake", "Ichigo Hotcake", "いちごホットケーキ", .tea,
             [.strawberry, .pancake], 1100, "DishIchigoHotcake",
             "Kissaten-style hotcakes with fresh strawberries. A Tokyo afternoon on a plate.",
             "Set a strawberry against a pancake. Cream is implied."),
        dish("matcha-daifuku", "Matcha Daifuku", "抹茶大福", .tea,
             [.tea, .mochi], 1000, "DishMatchaDaifuku",
             "Frothy matcha beside a chewy daifuku. The quiet luxury of a tea house.",
             "Park mochi next to tea. Whisked green, pink chew."),
        dish("shiso-sencha", "Shiso Sencha", "しそ煎茶", .tea,
             [.tea, .leaf], 800, "DishMatchaDaifuku",
             "Hot tea with a shiso leaf laid on the saucer. Herbal, bright, a little wild.",
             "A shiso leaf touching the cup is enough."),
        dish("ichigo-daifuku", "Ichigo Daifuku", "いちご大福", .tea,
             [.strawberry, .mochi], 1200, "DishIchigoHotcake",
             "A whole strawberry wrapped in a mochi. The wagashi that looks like a secret.",
             "Strawberry against mochi. The rice dough does the wrapping."),
        dish("ichigo-afternoon", "Strawberry Tea Set", "いちごティーセット", .tea,
             [.tea, .cookie, .strawberry], 1500, "DishAfternoonTea",
             "Tea, a biscuit, and a strawberry on the same tray. The set they bring when someone is visiting.",
             "Connect tea, cookie, and strawberry in one cluster."),
    ]

    private static let bento: [DishRecipe] = [
        dish("shake-onigiri", "Shake Onigiri", "鮭おにぎり", .bento,
             [.onigiri, .salmon], 1100, "DishShakeOnigiri",
             "Salted salmon tucked into a rice ball. Japan’s most honest packed lunch.",
             "Onigiri beside salmon. The rice takes the fish."),
        dish("ebi-bento", "Ebi Fry Bento", "エビフライ弁当", .bento,
             [.onigiri, .shrimp], 1000, "DishEbiBento",
             "A fried shrimp next to rice. Station-bento energy, no timetable required.",
             "Onigiri beside shrimp. The crunch sits on the rice."),
        dish("tamagoyaki-bento", "Tamagoyaki Bento", "卵焼き弁当", .bento,
             [.onigiri, .tamago], 1000, "DishTamagoyaki",
             "Sweet rolled omelette beside rice. The square that makes a lunch feel like home.",
             "Onigiri beside tamagoyaki. Sweet egg, plain rice."),
        dish("tomato-onigiri", "Tomato Onigiri", "トマトおにぎり", .bento,
             [.onigiri, .tomato], 800, "DishShakeOnigiri",
             "A bright tomato against rice — the kids’ bento trick that still tastes like summer.",
             "Onigiri beside tomato. Color does half the work."),
        dish("seafood-box", "Seafood Box", "海鮮弁当", .bento,
             [.salmon, .shrimp], 900, "DishEbiBento",
             "Salmon and shrimp sharing a compartment. The expensive row of a department-store bento.",
             "Salmon against shrimp. No rice required, but rice is welcome."),
        dish("makunouchi", "Makunouchi", "幕の内弁当", .bento,
             [.onigiri, .salmon, .tamago], 1600, "DishTamagoyaki",
             "Rice, salmon, and tamagoyaki in one cluster. The classic packed lunch, condensed.",
             "Connect onigiri, salmon, and tamagoyaki. That is a real bento."),
        dish("shoyu-onigiri", "Shoyu Onigiri", "醤油おにぎり", .bento,
             [.onigiri, .soySauce], 1000, nil,
             "A rice ball brushed with soy sauce: crisp at the edges, deeply savory in the middle.",
             "Place soy sauce beside onigiri."),
        dish("teriyaki-salmon-bento", "Teriyaki Salmon Bento", "照り焼き鮭弁当", .bento,
             [.onigiri, .salmon, .soySauce], 1800, nil,
             "Salmon, rice, and a glossy soy glaze gathered into one compact lunch.",
             "Connect onigiri, salmon, and soy sauce in one cluster."),
    ]

    private static let thai: [DishRecipe] = [
        dish("coconut-shrimp", "Coconut Shrimp", "กุ้งมะพร้าว", .thai,
             [.shrimp, .coconut], 1100, nil,
             "Juicy shrimp with mellow coconut. Sweet and savory in one quick street-side bite.",
             "Place shrimp beside coconut."),
        dish("tom-yum", "Tom Yum", "ต้มยำกุ้ง", .thai,
             [.shrimp, .lime, .leaf], 1700, nil,
             "A bright, aromatic shrimp soup built around sour lime and fragrant herbs.",
             "Connect shrimp, lime, and a fresh leaf in one cluster."),
        dish("lime-tea", "Thai Lime Tea", "ชามะนาว", .thai,
             [.tea, .lime], 900, nil,
             "Chilled tea sharpened with lime — cooling, fragrant, and made for a warm evening.",
             "Place tea beside lime."),
        dish("coconut-lime", "Coconut Lime Cup", "มะพร้าวมะนาว", .thai,
             [.coconut, .lime], 1000, nil,
             "Creamy coconut cut with a clean squeeze of lime.",
             "Place coconut beside lime."),
        dish("thai-garden", "Thai Garden Plate", "ยำสวน", .thai,
             [.tomato, .lime, .leaf], 1500, nil,
             "Tomato, lime, and herbs tossed into a sharp little salad.",
             "Connect tomato, lime, and a fresh leaf."),
        dish("ginger-lime-tea", "Ginger Lime Tea", "ชาขิงมะนาว", .thai,
             [.tea, .ginger, .lime], 1600, nil,
             "Warm ginger tea sharpened with lime — bright enough for a humid market evening.",
             "Connect tea, ginger, and lime."),
        dish("ginger-shrimp", "Ginger Lime Shrimp", "กุ้งขิงมะนาว", .thai,
             [.shrimp, .ginger, .lime], 1800, nil,
             "Shrimp tossed with fragrant ginger and a clean squeeze of lime.",
             "Connect shrimp, ginger, and lime."),
        dish("coconut-ginger-cup", "Coconut Ginger Cup", "มะพร้าวขิง", .thai,
             [.coconut, .ginger, .tea], 1600, nil,
             "A mellow coconut drink warmed with ginger and tea.",
             "Connect coconut, ginger, and tea."),
    ]

    private static let israeli: [DishRecipe] = [
        dish("hummus-pita", "Hummus & Pita", "חומוס ופיתה", .israeli,
             [.hummus, .pita], 1100, nil,
             "Creamy hummus and warm pita: a simple plate that belongs in the middle of the table.",
             "Place hummus beside pita."),
        dish("israeli-salad", "Israeli Salad", "סלט ישראלי", .israeli,
             [.tomato, .lime, .leaf], 1500, nil,
             "Finely chopped tomato, herbs, and a bright squeeze of citrus.",
             "Connect tomato, lime, and a fresh leaf."),
        dish("sabich-pocket", "Sabich Pocket", "סביח", .israeli,
             [.pita, .tamago, .tomato], 1700, nil,
             "A playful Snackdraft take on the loaded pita: egg, tomato, and warm bread.",
             "Connect pita, tamagoyaki, and tomato."),
        dish("mezze-plate", "Mezze Plate", "צלחת מזטים", .israeli,
             [.hummus, .pita, .tomato], 1600, nil,
             "Hummus, pita, and tomato gathered into a generous shared plate.",
             "Connect hummus, pita, and tomato."),
        dish("green-hummus", "Green Hummus Plate", "חומוס ירוק", .israeli,
             [.hummus, .leaf, .lime], 1500, nil,
             "Hummus brightened with herbs and citrus.",
             "Connect hummus, leaf, and lime."),
        dish("labneh-pita", "Labneh & Pita", "לבנה ופיתה", .israeli,
             [.yogurt, .pita], 1100, nil,
             "Cool, thick labneh scooped up with warm pita.",
             "Place yogurt beside pita."),
        dish("olive-hummus", "Olive Hummus", "חומוס וזיתים", .israeli,
             [.hummus, .olive], 1100, nil,
             "Creamy hummus finished with a small briny pile of olives.",
             "Place olives beside hummus."),
        dish("yogurt-salad", "Yogurt Garden Salad", "סלט יוגורט", .israeli,
             [.yogurt, .tomato, .leaf], 1600, nil,
             "Cool yogurt, chopped tomato, and fresh herbs on one sunny plate.",
             "Connect yogurt, tomato, and a leaf."),
        dish("long-mezze", "Long Mezze Table", "שולחן מזטים", .israeli,
             [.hummus, .pita, .olive, .tomato], 2300, nil,
             "Hummus, pita, olives, and tomato — enough little plates to make everyone stay.",
             "Connect all four ingredients in one shared cluster."),
    ]

    private static let italian: [DishRecipe] = [
        dish("pasta-pomodoro", "Pasta al Pomodoro", "Pasta al pomodoro", .italian,
             [.pasta, .tomato], 1100, nil,
             "Golden pasta with a clean tomato sauce — the lesson that simple can still be complete.",
             "Place pasta beside tomato."),
        dish("pasta-formaggio", "Pasta al Formaggio", "Pasta al formaggio", .italian,
             [.pasta, .cheese], 1000, nil,
             "Warm pasta and melting cheese, built for comfort.",
             "Place pasta beside cheese."),
        dish("caprese", "Caprese", "Insalata caprese", .italian,
             [.tomato, .cheese, .leaf], 1600, nil,
             "Tomato, cheese, and a fresh herb in the colors of an Italian summer.",
             "Connect tomato, cheese, and a fresh leaf."),
        dish("pasta-primavera", "Pasta Primavera", "Pasta primavera", .italian,
             [.pasta, .tomato, .leaf], 1700, nil,
             "Pasta lifted with tomato and garden herbs.",
             "Connect pasta, tomato, and a fresh leaf."),
        dish("creamy-pasta", "Creamy Avocado Pasta", "Pasta cremosa", .italian,
             [.pasta, .avocado, .lime], 1600, nil,
             "A modern green pasta: creamy avocado with a bright citrus finish.",
             "Connect pasta, avocado, and lime."),
        dish("aglio-olio", "Pasta Aglio", "Aglio e olio", .italian,
             [.pasta, .garlic], 1200, nil,
             "Golden pasta with garlic perfume — proof that two ingredients can be a whole idea.",
             "Place garlic beside pasta."),
        dish("pasta-funghi", "Pasta ai Funghi", "Pasta ai funghi", .italian,
             [.pasta, .mushroom], 1200, nil,
             "Earthy mushroom folded through warm pasta.",
             "Place mushroom beside pasta."),
        dish("olive-caprese", "Olive Caprese", "Caprese alle olive", .italian,
             [.tomato, .cheese, .olive], 1700, nil,
             "Tomato and cheese with a briny olive finish.",
             "Connect tomato, cheese, and olives."),
        dish("funghi-aglio", "Garlic Mushroom Pasta", "Pasta funghi e aglio", .italian,
             [.pasta, .mushroom, .garlic], 1900, nil,
             "Mushroom and garlic gathered around pasta in one deep, aromatic bowl.",
             "Connect pasta, mushroom, and garlic."),
        dish("trattoria-board", "Trattoria Board", "Tavola della trattoria", .italian,
             [.pasta, .tomato, .olive, .mushroom], 2400, nil,
             "Pasta, tomatoes, olives, and mushrooms spread across the table for a long lunch.",
             "Connect all four ingredients in one cluster."),
    ]

    private static let garden: [DishRecipe] = [
        dish("blueberry-hotcake", "Blueberry Hotcake", "ブルーベリーホットケーキ", .garden,
             [.blueberry, .pancake], 1100, "DishBlueberryHotcake",
             "Garden berries on a fluffy stack. Weekend morning, no alarm.",
             "Blueberries touching a pancake. Butter is a rumor."),
        dish("garden-salad", "Garden Salad", "アボカドトマト", .garden,
             [.avocado, .tomato], 900, "DishGardenSalad",
             "Avocado and tomato, a little sun and a little cream. Two bites of the garden.",
             "Avocado against tomato. Add shiso if you have it."),
        dish("mixed-berry", "Mixed Berry", "ミックスベリー", .garden,
             [.strawberry, .blueberry], 900, "DishBlueberryHotcake",
             "Strawberry and blueberry sharing a bowl. The garden before anyone cooks.",
             "The two berries touching. That is the bowl."),
        dish("shiso-tomato", "Shiso Tomato", "しそトマト", .garden,
             [.tomato, .leaf], 800, "DishGardenSalad",
             "Tomato with a shiso leaf. The side dish that tastes like a garden wall in August.",
             "Tomato beside shiso. Salt is imaginary and perfect."),
        dish("berry-garden-plate", "Berry Garden Plate", "ベリーガーデン", .garden,
             [.strawberry, .blueberry, .pancake], 1600, "DishBlueberryHotcake",
             "Both berries on a hotcake. The garden brunch you meant to photograph.",
             "Connect strawberry, blueberry, and pancake."),
        dish("green-plate", "Green Plate", "グリーンプレート", .garden,
             [.avocado, .tomato, .leaf], 1400, "DishGardenSalad",
             "Avocado, tomato, shiso. A salad that still fits in a bento corner.",
             "Connect avocado, tomato, and shiso in one cluster."),
    ]

    private static let kitchen: [DishRecipe] = [
        dish("rainy-breakfast", "Rainy Breakfast", "雨の朝ごはん", .kitchen,
             [.bacon, .tamago], 1100, "DishRainyBreakfast",
             "Bacon and rolled egg while the window beads with rain. A kitchen that refuses to hurry.",
             "Bacon beside tamagoyaki. The kettle can wait."),
        dish("bacon-hotcake", "Bacon Hotcake", "ベーコンホットケーキ", .kitchen,
             [.bacon, .pancake], 1000, "DishRainyBreakfast",
             "Salty bacon on a sweet stack. The American diner that moved into a small kitchen.",
             "Bacon against pancake. Syrup is a mood, not a piece."),
        dish("cheese-tamago", "Cheese Tamago", "チーズ卵焼き", .kitchen,
             [.cheese, .tamago], 900, "DishTamagoyaki",
             "Rolled egg with a cube of cheese melting at the edge. Kid lunch, grown-up comfort.",
             "Cheese touching tamagoyaki. Let it sit."),
        dish("builders-tea", "Builder’s Tea", "ビルダーズティー", .kitchen,
             [.tea, .cookie], 800, "DishAfternoonTea",
             "Strong tea and a biscuit at the counter. Not a ceremony. A pause that works.",
             "Tea beside a cookie, same as afternoon tea, less porcelain."),
        dish("full-skillet", "Full Skillet", "フルスキレット", .kitchen,
             [.bacon, .tamago, .pancake], 1600, "DishRainyBreakfast",
             "Bacon, egg, and a pancake in one cluster. The rainy morning, finished.",
             "Connect bacon, tamagoyaki, and pancake. That is breakfast."),
    ]

    private static let mexican: [DishRecipe] = [
        dish("bean-taco", "Bean Taco", "Taco de frijoles", .mexican,
             [.tortilla, .beans], 1100, nil,
             "Warm corn tortilla folded around glossy black beans — small, sturdy, and deeply satisfying.",
             "Place tortilla beside black beans."),
        dish("guacamole", "Guacamole", "Guacamole", .mexican,
             [.avocado, .lime], 1000, nil,
             "Creamy avocado sharpened with lime. The bright green bowl every market table needs.",
             "Place avocado beside lime."),
        dish("salsa-roja", "Salsa Roja", "Salsa roja", .mexican,
             [.tomato, .chili, .lime], 1600, nil,
             "Tomato, red chili, and lime crushed into a vivid table salsa.",
             "Connect tomato, chili, and lime in one cluster."),
        dish("loaded-taco", "Loaded Taco", "Taco completo", .mexican,
             [.tortilla, .beans, .tomato], 1700, nil,
             "A bean taco finished with juicy tomato — a whole market lunch in one fold.",
             "Connect tortilla, beans, and tomato."),
        dish("guacamole-taco", "Guacamole Taco", "Taco de aguacate", .mexican,
             [.tortilla, .avocado, .lime], 1700, nil,
             "Warm tortilla, cool avocado, and lime arranged as one clean, green bite.",
             "Connect tortilla, avocado, and lime."),
        dish("mango-chile-cup", "Mango Chile Cup", "Mango con chile", .mexican,
             [.mango, .chili, .lime], 1700, nil,
             "Ripe mango with lime and a red spark of chili — sweet, sour, and hot in turns.",
             "Connect mango, chili, and lime."),
        dish("elote-cup", "Elote Cup", "Esquites", .mexican,
             [.corn, .chili, .lime], 1700, nil,
             "Sweet corn, lime, and chili in a bright market cup.",
             "Connect corn, chili, and lime."),
        dish("corn-taco", "Corn & Bean Taco", "Taco de maíz", .mexican,
             [.tortilla, .corn, .beans], 1800, nil,
             "A warm tortilla packed with sweet corn and earthy beans.",
             "Connect tortilla, corn, and beans."),
        dish("avocado-corn", "Avocado Corn Cup", "Vaso de aguacate y maíz", .mexican,
             [.corn, .avocado, .lime], 1700, nil,
             "Creamy avocado and sunny corn lifted with lime.",
             "Connect corn, avocado, and lime."),
    ]

    private static let indian: [DishRecipe] = [
        dish("curry-naan", "Curry & Naan", "करी और नान", .indian,
             [.curry, .naan], 1200, nil,
             "A warm bowl of curry with blistered naan ready to scoop it clean.",
             "Place curry beside naan."),
        dish("mango-lassi", "Mango Lassi", "आम लस्सी", .indian,
             [.mango, .coconut], 1100, nil,
             "A playful dairy-free Snackdraft cooler: ripe mango softened with coconut.",
             "Place mango beside coconut."),
        dish("chili-curry", "Chili Curry", "मसाला करी", .indian,
             [.curry, .chili], 1000, nil,
             "Golden curry with a bright red edge of heat.",
             "Place curry beside chili."),
        dish("coconut-curry", "Coconut Curry", "नारियल करी", .indian,
             [.curry, .coconut, .tomato], 1700, nil,
             "Curry rounded with coconut and a fresh tomato base.",
             "Connect curry, coconut, and tomato."),
        dish("masala-thali", "Masala Thali", "मसाला थाली", .indian,
             [.curry, .naan, .chili], 1800, nil,
             "Curry, naan, and chili sharing one compact thali cluster.",
             "Connect curry, naan, and chili."),
        dish("mango-chutney", "Mango Chutney", "आम की चटनी", .indian,
             [.mango, .chili, .lime], 1600, nil,
             "Mango, chili, and lime balanced into a sweet, sharp condiment.",
             "Connect mango, chili, and lime."),
        dish("true-mango-lassi", "Mango Yogurt Lassi", "आम की लस्सी", .indian,
             [.mango, .yogurt], 1200, nil,
             "Ripe mango and cool yogurt blended into the classic soft drink.",
             "Place mango beside yogurt."),
        dish("ginger-curry", "Ginger Curry", "अदरक करी", .indian,
             [.curry, .ginger], 1200, nil,
             "Warm curry lifted by the clear fragrance of fresh ginger.",
             "Place ginger beside curry."),
        dish("creamy-curry", "Creamy Curry Plate", "दही करी", .indian,
             [.curry, .yogurt, .naan], 1900, nil,
             "Curry mellowed with yogurt and served beside naan.",
             "Connect curry, yogurt, and naan."),
        dish("ginger-raita-thali", "Ginger Raita Thali", "अदरक रायता थाली", .indian,
             [.curry, .ginger, .yogurt, .naan], 2400, nil,
             "Hot curry, fragrant ginger, cool yogurt, and naan balanced in one complete thali.",
             "Connect all four ingredients in one cluster."),
    ]

    private static func dish(
        _ id: String,
        _ name: String,
        _ subtitle: String,
        _ world: WorldID,
        _ required: [SnackID],
        _ bonus: Int,
        _ asset: String?,
        _ blurb: String,
        _ method: String
    ) -> DishRecipe {
        DishRecipe(
            id: id,
            name: name,
            subtitle: subtitle,
            world: world,
            required: required,
            bonus: bonus,
            assetName: asset,
            blurb: blurb,
            method: method
        )
    }
}
