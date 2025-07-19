<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Artisan;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $this->call([
            CategorySeeder::class,
            DivisionSeeder::class,
            LocationSeeder::class,
            ProductSeeder::class,
            InnovationStorySeeder::class,
            PageSeeder::class,
        ]);

        $this->command->info(PHP_EOL);
        $this->command->line('  <fg=blue>████████████████████████████████████████████</fg=blue>');
        $this->command->line('  <fg=blue>█</fg=blue>                                          <fg=blue>█</fg=blue>');
        $this->command->line('  <fg=blue>█</fg=blue>    <fg=white>🍎 SALBION GROUP EXPERIENCE</fg=white>        <fg=blue>█</fg=blue>');
        $this->command->line('  <fg=blue>█</fg=blue>    <fg=white>Apple-Style Innovation Platform</fg=white>      <fg=blue>█</fg=blue>');
        $this->command->line('  <fg=blue>█</fg=blue>                                          <fg=blue>█</fg=blue>');
        $this->command->line('  <fg=blue>████████████████████████████████████████████</fg=blue>');
        $this->command->info(PHP_EOL);
        
        $this->command->info('✨ <fg=green>Successfully Installed:</fg=green>');
        $this->command->line('   • 5 Innovation Divisions with AI-powered solutions');
        $this->command->line('   • 6 Flagship Products with Apple-style presentations');
        $this->command->line('   • 6 Global Locations with detailed capabilities');
        $this->command->line('   • 2 Innovation Stories showcasing real impact');
        $this->command->line('   • 3 Strategic Pages with immersive content');
        $this->command->info(PHP_EOL);
        
        $this->command->info('🚀 <fg=yellow>Experience Highlights:</fg=yellow>');
        $this->command->line('   • Apple-inspired minimalist design system');
        $this->command->line('   • Cross-industry innovation narrative');
        $this->command->line('   • Global presence with local expertise');
        $this->command->line('   • Sustainability-first approach');
        $this->command->line('   • Human-centered AI philosophy');
        $this->command->info(PHP_EOL);
        
        $this->command->info('🎯 <fg=cyan>Next Steps:</fg=cyan>');
        $this->command->line('   1. Visit <fg=white>/admin</fg=white> to explore the enhanced admin experience');
        $this->command->line('   2. Check out <fg=white>/innovation</fg=white> for the philosophy showcase');
        $this->command->line('   3. Explore <fg=white>/locations</fg=white> for global presence mapping');
        $this->command->line('   4. Browse flagship products with Apple-style presentations');
        $this->command->info(PHP_EOL);
    }
}
