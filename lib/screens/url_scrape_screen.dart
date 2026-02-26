import 'dart:async';

import 'package:flutter/material.dart';
import '../services/scrape_service.dart';
import '../services/site_detector.dart';
import '../models/scrape_job.dart';
import '../models/extracted_product.dart';
import '../widgets/url_input_field.dart';
import '../widgets/scrape_progress.dart';
import '../widgets/extraction_result_form.dart';
import '../widgets/scrape_error_view.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/responsive_container.dart';

enum _ScrapeState { input, loading, result, error }

class UrlScrapeScreen extends StatefulWidget {
  const UrlScrapeScreen({super.key});

  @override
  State<UrlScrapeScreen> createState() => _UrlScrapeScreenState();
}

class _UrlScrapeScreenState extends State<UrlScrapeScreen> {
  _ScrapeState _state = _ScrapeState.input;

  // Loading state
  int _currentStep = 0;
  String _progressMessage = '';
  int _estimatedSeconds = 0;

  // Result state
  ExtractedProduct? _extractedProduct;

  // Error state
  ScrapeErrorCode? _errorCode;
  String? _errorMessage;

  StreamSubscription<ScrapeJob>? _subscription;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _onUrlSubmit(String url, SupportedSite site) {
    _subscription?.cancel();

    setState(() {
      _state = _ScrapeState.loading;
      _currentStep = 0;
      _progressMessage = '요청을 준비하고 있습니다...';
      _estimatedSeconds = 9;
    });

    _subscription = ScrapeService.startScraping(url).listen(
      (job) {
        if (!mounted) return;
        switch (job.status) {
          case ScrapeStatus.pending:
          case ScrapeStatus.crawling:
          case ScrapeStatus.parsing:
          case ScrapeStatus.processing:
            setState(() {
              _state = _ScrapeState.loading;
              _currentStep = job.progress?.step ?? 0;
              _progressMessage = job.progress?.message ?? '';
              _estimatedSeconds = job.estimatedSeconds;
            });
          case ScrapeStatus.done:
            setState(() {
              _state = _ScrapeState.result;
              _extractedProduct = job.result;
            });
          case ScrapeStatus.failed:
            setState(() {
              _state = _ScrapeState.error;
              _errorCode = job.errorCode;
              _errorMessage = job.errorMessage;
            });
        }
      },
      onError: (_) {
        if (!mounted) return;
        setState(() {
          _state = _ScrapeState.error;
          _errorCode = ScrapeErrorCode.parseError;
          _errorMessage = null;
        });
      },
    );
  }

  void _onRetry() {
    setState(() {
      _state = _ScrapeState.input;
      _errorCode = null;
      _errorMessage = null;
    });
  }

  void _onManualInput() {
    Navigator.of(context).pop(null);
  }

  void _onProductChanged(ExtractedProduct updated) {
    setState(() => _extractedProduct = updated);
  }

  void _onConfirm() {
    Navigator.of(context).pop(_extractedProduct);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(null),
        ),
        title: Text(
          'URL로 빠른 등록',
          style: AppTextStyles.titleMedium,
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      body: ResponsiveContainer.form(
        child: _buildBody(isDesktop),
      ),
    );
  }

  Widget _buildBody(bool isDesktop) {
    switch (_state) {
      case _ScrapeState.input:
        return _buildInputState(isDesktop);
      case _ScrapeState.loading:
        return _buildLoadingState();
      case _ScrapeState.result:
        return _buildResultState(isDesktop);
      case _ScrapeState.error:
        return _buildErrorState();
    }
  }

  Widget _buildInputState(bool isDesktop) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? AppSpacing.xxxxl : AppSpacing.xl,
        vertical: isDesktop ? AppSpacing.xxxxl : AppSpacing.xxxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '상품 URL 입력',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '쇼핑몰 상품 페이지 URL을 입력하면 상품 정보를 자동으로 불러옵니다.',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          UrlInputField(onSubmit: _onUrlSubmit),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return ScrapeProgressView(
      currentStep: _currentStep,
      message: _progressMessage,
      estimatedSeconds: _estimatedSeconds,
    );
  }

  Widget _buildResultState(bool isDesktop) {
    final product = _extractedProduct;
    if (product == null) {
      return Center(
        child: Text(
          '상품 정보를 불러올 수 없습니다.',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? AppSpacing.xxxxl : AppSpacing.xl,
        vertical: isDesktop ? AppSpacing.xxxl : AppSpacing.xl,
      ),
      child: ExtractionResultForm(
        product: product,
        onChanged: _onProductChanged,
        onConfirm: _onConfirm,
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: SingleChildScrollView(
        child: ScrapeErrorView(
          errorCode: _errorCode ?? ScrapeErrorCode.parseError,
          errorMessage: _errorMessage,
          onRetry: _onRetry,
          onManualInput: _onManualInput,
        ),
      ),
    );
  }
}
