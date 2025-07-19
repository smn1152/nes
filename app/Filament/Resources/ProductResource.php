<?php

namespace App\Filament\Resources;

use App\Filament\Resources\ProductResource\Pages;
use App\Models\Product;
use Filament\Forms;
use Filament\Forms\Components\Grid;
use Filament\Forms\Components\Section;
use Filament\Forms\Components\Tabs;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Str;

class ProductResource extends Resource
{
    protected static ?string $model = Product::class;

    protected static ?string $navigationIcon = 'heroicon-o-cube';

    protected static ?string $navigationGroup = 'Products';

    protected static ?int $navigationSort = 1;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Tabs::make('Product Details')
                    ->tabs([
                        Tabs\Tab::make('Basic Information')
                            ->schema([
                                Section::make()
                                    ->schema([
                                        Grid::make(2)
                                            ->schema([
                                                Forms\Components\TextInput::make('name')
                                                    ->required()
                                                    ->maxLength(255)
                                                    ->live(onBlur: true)
                                                    ->afterStateUpdated(fn (string $state, Forms\Set $set) => $set('slug', Str::slug($state))
                                                    ),
                                                Forms\Components\TextInput::make('slug')
                                                    ->required()
                                                    ->maxLength(255)
                                                    ->unique(ignoreRecord: true),
                                            ]),

                                        Forms\Components\TextInput::make('tagline')
                                            ->maxLength(255),

                                        Forms\Components\Textarea::make('description')
                                            ->rows(3)
                                            ->columnSpanFull(),

                                        Grid::make(3)
                                            ->schema([
                                                Forms\Components\TextInput::make('price')
                                                    ->numeric()
                                                    ->prefix('£')
                                                    ->required(),
                                                Forms\Components\TextInput::make('sku')
                                                    ->label('SKU')
                                                    ->unique(ignoreRecord: true),
                                                Forms\Components\TextInput::make('product_family')
                                                    ->maxLength(255),
                                            ]),
                                    ]),
                            ]),

                        Tabs\Tab::make('Technical Details')
                            ->schema([
                                Section::make()
                                    ->schema([
                                        Forms\Components\KeyValue::make('specifications')
                                            ->reorderable()
                                            ->columnSpanFull(),

                                        Forms\Components\Repeater::make('features')
                                            ->schema([
                                                Forms\Components\TextInput::make('feature')
                                                    ->required(),
                                            ])
                                            ->columnSpanFull(),

                                        Forms\Components\Repeater::make('use_cases')
                                            ->schema([
                                                Forms\Components\TextInput::make('use_case')
                                                    ->required(),
                                            ])
                                            ->columnSpanFull(),

                                        Forms\Components\KeyValue::make('comparison_points')
                                            ->columnSpanFull(),

                                        Forms\Components\KeyValue::make('technical_docs')
                                            ->columnSpanFull(),
                                    ]),
                            ]),

                        Tabs\Tab::make('Media')
                            ->schema([
                                Section::make()
                                    ->schema([
                                        Forms\Components\SpatieMediaLibraryFileUpload::make('hero_image')
                                            ->collection('hero_image')
                                            ->label('Hero Image')
                                            ->image()
                                            ->optimize('webp'),

                                        Forms\Components\SpatieMediaLibraryFileUpload::make('gallery')
                                            ->collection('gallery')
                                            ->label('Gallery Images')
                                            ->multiple()
                                            ->image()
                                            ->optimize('webp')
                                            ->reorderable(),

                                        Forms\Components\SpatieMediaLibraryFileUpload::make('hero_video')
                                            ->collection('hero_video')
                                            ->label('Hero Video')
                                            ->acceptedFileTypes(['video/mp4', 'video/webm']),

                                        Forms\Components\SpatieMediaLibraryFileUpload::make('technical_drawings')
                                            ->collection('technical_drawings')
                                            ->label('Technical Drawings')
                                            ->multiple()
                                            ->acceptedFileTypes(['application/pdf', 'image/*']),
                                    ]),
                            ]),

                        Tabs\Tab::make('SEO & Organization')
                            ->schema([
                                Section::make('SEO')
                                    ->schema([
                                        Forms\Components\TextInput::make('meta_title')
                                            ->maxLength(255),
                                        Forms\Components\Textarea::make('meta_description')
                                            ->rows(2),
                                        Forms\Components\TagsInput::make('keywords'),
                                    ]),

                                Section::make('Organization')
                                    ->schema([
                                        Grid::make(2)
                                            ->schema([
                                                Forms\Components\Select::make('category_id')
                                                    ->relationship('category', 'name')
                                                    ->searchable()
                                                    ->preload(),
                                                Forms\Components\Select::make('division_id')
                                                    ->relationship('division', 'name')
                                                    ->searchable()
                                                    ->preload(),
                                            ]),

                                        Forms\Components\Select::make('user_id')
                                            ->relationship('user', 'name')
                                            ->label('Product Manager')
                                            ->searchable()
                                            ->preload(),

                                        Forms\Components\TextInput::make('innovation_score')
                                            ->numeric()
                                            ->minValue(0)
                                            ->maxValue(100)
                                            ->suffix('/ 100'),
                                    ]),
                            ]),

                        Tabs\Tab::make('Visibility')
                            ->schema([
                                Section::make()
                                    ->schema([
                                        Grid::make(2)
                                            ->schema([
                                                Forms\Components\Toggle::make('is_active')
                                                    ->label('Active')
                                                    ->default(true),
                                                Forms\Components\Toggle::make('is_featured')
                                                    ->label('Featured'),
                                            ]),

                                        Forms\Components\DateTimePicker::make('launch_date')
                                            ->label('Launch Date'),
                                    ]),
                            ]),
                    ])
                    ->columnSpanFull(),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\SpatieMediaLibraryImageColumn::make('hero_image')
                    ->collection('hero_image')
                    ->square()
                    ->size(60),
                Tables\Columns\TextColumn::make('name')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('sku')
                    ->searchable()
                    ->toggleable(),
                Tables\Columns\TextColumn::make('price')
                    ->money('GBP')
                    ->sortable(),
                Tables\Columns\TextColumn::make('product_family')
                    ->searchable()
                    ->toggleable(),
                Tables\Columns\TextColumn::make('category.name')
                    ->toggleable(),
                Tables\Columns\TextColumn::make('division.name')
                    ->toggleable(),
                Tables\Columns\TextColumn::make('innovation_score')
                    ->suffix('/100')
                    ->color(fn (int $state): string => match (true) {
                        $state >= 80 => 'success',
                        $state >= 50 => 'warning',
                        default => 'danger',
                    })
                    ->toggleable(),
                Tables\Columns\IconColumn::make('is_active')
                    ->boolean()
                    ->label('Active'),
                Tables\Columns\IconColumn::make('is_featured')
                    ->boolean()
                    ->label('Featured')
                    ->toggleable(),
                Tables\Columns\TextColumn::make('launch_date')
                    ->date()
                    ->sortable()
                    ->toggleable(),
                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\TernaryFilter::make('is_active')
                    ->label('Active'),
                Tables\Filters\TernaryFilter::make('is_featured')
                    ->label('Featured'),
                Tables\Filters\SelectFilter::make('category')
                    ->relationship('category', 'name'),
                Tables\Filters\SelectFilter::make('division')
                    ->relationship('division', 'name'),
                Tables\Filters\Filter::make('high_innovation')
                    ->query(fn (Builder $query): Builder => $query->where('innovation_score', '>=', 80)),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                    Tables\Actions\BulkAction::make('activate')
                        ->label('Activate')
                        ->icon('heroicon-o-check-circle')
                        ->action(fn ($records) => $records->each->update(['is_active' => true]))
                        ->deselectRecordsAfterCompletion(),
                ]),
            ])
            ->defaultSort('created_at', 'desc');
    }

    public static function getRelations(): array
    {
        return [
            // Add relation managers here if needed
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListProducts::route('/'),
            'create' => Pages\CreateProduct::route('/create'),
            'edit' => Pages\EditProduct::route('/{record}/edit'),
        ];
    }

    public static function getGloballySearchableAttributes(): array
    {
        return ['name', 'sku', 'description', 'tagline', 'product_family'];
    }
}
