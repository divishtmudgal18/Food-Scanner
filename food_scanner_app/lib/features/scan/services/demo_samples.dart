class DemoSampleItem {
  final String title;
  final String description;
  final String rawOcrText;

  const DemoSampleItem({
    required this.title,
    required this.description,
    required this.rawOcrText,
  });
}

class DemoSamples {
  static final List<DemoSampleItem> samples = [
    const DemoSampleItem(
      title: 'Oat & Almond Granola Bar',
      description: 'Healthy profile, valid Best Before, low sugar, high protein.',
      rawOcrText: '''
NATURE VALLEY
Oat & Almond Granola Bar
BATCH NO: B8291
BEST BEFORE: 24-DEC-2027
INGREDIENTS: Whole grain rolled oats, roasted almonds, honey, chia seeds, sea salt.
ALLERGENS: Contains tree nuts (almonds). May contain traces of soy.
NUTRITION FACTS
Serving Size: 40g
Calories: 160 kcal
Total Carbohydrates: 22g
Total Sugars: 4.5g
Dietary Fiber: 4g
Protein: 9g
Total Fat: 5g
Saturated Fat: 0.5g
Sodium: 85mg
Store in a cool dry place.
''',
    ),
    const DemoSampleItem(
      title: 'Berry Gummy Candies',
      description: 'High sugar goal conflict & gelatin (non-vegetarian) mismatch.',
      rawOcrText: '''
HARIBO SWEET TREATS
Berry Gummy Candies
LOT: 99482
BEST BEFORE: 18/08/2027
INGREDIENTS: Glucose syrup, sugar, gelatin, citric acid, concentrated fruit juices, carmine color, beeswax.
ALLERGENS: None declared.
NUTRITION FACTS
Serving Size: 30g
Calories: 110 kcal
Total Carbohydrates: 25g
Total Sugars: 19g
Protein: 1.5g
Total Fat: 0g
Sodium: 20mg
''',
    ),
    const DemoSampleItem(
      title: 'Crunchy Peanut Butter Cups',
      description: 'Direct allergen conflict for peanut-sensitive users.',
      rawOcrText: '''
REESE'S
Milk Chocolate Peanut Butter Cups
EXP DATE: 12/11/2026
INGREDIENTS: Milk chocolate (sugar, cocoa butter, chocolate, skim milk, lactose), peanuts, sugar, dextrose, salt, TBHQ.
CONTAINS: Peanuts, Milk, Soy.
NUTRITION FACTS
Serving Size: 42g
Calories: 220 kcal
Total Sugars: 22g
Protein: 5g
Total Fat: 13g
Sodium: 150mg
''',
    ),
    const DemoSampleItem(
      title: 'Fresh Plain Greek Yogurt',
      description: 'Expiring soon check (within 3 days), high protein, low sodium.',
      rawOcrText: '''
CHOBANI
Plain Greek Yogurt
BATCH: YOG-772
USE BY 23/10/2026
INGREDIENTS: Cultured pasteurized nonfat milk, live and active cultures.
CONTAINS: Milk.
NUTRITION FACTS
Serving Size: 170g
Calories: 90 kcal
Total Sugars: 4g
Protein: 16g
Total Fat: 0g
Sodium: 65mg
Keep refrigerated at 4°C.
''',
    ),
    const DemoSampleItem(
      title: 'Organic Black Beans',
      description: 'Past printed date (expired test case).',
      rawOcrText: '''
EDEN FOODS
Organic Black Beans
USE BY 15/01/2022
INGREDIENTS: Organic black turtle beans, water, kombu seaweed.
NUTRITION FACTS
Serving Size: 130g
Calories: 100 kcal
Total Sugars: 1g
Protein: 7g
Dietary Fiber: 7g
Sodium: 15mg
''',
    ),
    const DemoSampleItem(
      title: 'Ambiguous Date Chips',
      description: 'EXP: 05/06/2026 (triggers manual confirmation dialog).',
      rawOcrText: '''
LAYS CLASSIC
Potato Chips
EXP: 05/06/2026
INGREDIENTS: Potatoes, vegetable oil (sunflower, corn, and/or canola oil), salt.
NUTRITION FACTS
Serving Size: 28g
Calories: 160 kcal
Total Sugars: 0g
Protein: 2g
Total Fat: 10g
Saturated Fat: 1.5g
Sodium: 170mg
''',
    ),
  ];
}
